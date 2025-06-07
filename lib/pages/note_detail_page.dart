// lib/pages/note_detail_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// Updated import: no alias, we’ll use AudioRecorder
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/omni_note.dart';
import '../models/attachment.dart';
import '../services/omni_note_service.dart';
import '../services/ai_service.dart';

enum NoteMode { text, voice, image, video }

class NoteDetailPage extends StatefulWidget {
  final OmniNote? omniNote;
  final NoteMode initialMode;

  const NoteDetailPage({
    super.key,
    this.omniNote,
    this.initialMode = NoteMode.text,
  });

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _contentCtl = TextEditingController();

  String _title = '';
  String _subtitle = '';
  String _content = '';
  ZoneTheme _zone = ZoneTheme.Fusion;
  List<String> _customTags = [];

  bool _isGenerating = false;
  List<String> _aiTags = [];
  final Set<String> _pickedTags = {};

  Color _noteColor = Colors.white;
  String? _mood, _direction, _projectId;

  late NoteMode _mode;

  File? _imageFile;
  File? _videoFile;

  // New API: AudioRecorder instead of Record
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _audioPath;
  AudioPlayer? _player;
  PlayerState _playerState = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    if (widget.omniNote != null) _loadFromNote(widget.omniNote!);
    _contentCtl.addListener(_autoTag);
  }

  void _loadFromNote(OmniNote n) {
    _title = n.title;
    _subtitle = n.subtitle;
    _content = n.content;
    _contentCtl.text = _content;
    _zone = n.zone;
    _customTags = n.tags.split(',').where((s) => s.isNotEmpty).toList();
    _noteColor = Color(n.colorValue);
    _mood = n.mood;
    _direction = n.direction;
    _projectId = n.projectId;
    // Load attachments for viewing/playback
    final img = n.attachments
        .where((a) => a.type == AttachmentType.image)
        .map((a) => File(a.localPath))
        .firstWhere(
          (_) => true,
          orElse: () => File(''),
        );
    if (img.path.isNotEmpty) _imageFile = img;

    final vid = n.attachments
        .where((a) => a.type == AttachmentType.video)
        .map((a) => File(a.localPath))
        .firstWhere(
          (_) => true,
          orElse: () => File(''),
        );
    if (vid.path.isNotEmpty) _videoFile = vid;

    final aud = n.attachments
        .firstWhere(
          (a) => a.type == AttachmentType.audio,
          orElse: () => Attachment(localPath: '', type: AttachmentType.audio),
        )
        .localPath;
    if (aud.isNotEmpty) _audioPath = aud;
  }

  void _autoTag() async {
    final txt = _contentCtl.text.trim();
    if (_mode == NoteMode.text && txt.length > 5 && !_isGenerating) {
      setState(() => _isGenerating = true);
      final ai = await AIService.instance.generateRecommendedTag(txt);
      setState(() {
        _isGenerating = false;
        _aiTags = ai == null ? [] : [ai];
        if (widget.omniNote == null && ai != null) _pickedTags.add(ai);
      });
    }
  }

  Future<bool> _req(Permission p) async =>
      (await p.request()) == PermissionStatus.granted;

  Future<Directory> _notesDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final notes = Directory('${dir.path}/notes');
    if (!await notes.exists()) await notes.create(recursive: true);
    return notes;
  }

  Future<void> _pickImage() async {
    if (!await _req(Permission.camera)) return;
    final img = await ImagePicker().pickImage(source: ImageSource.camera);
    if (img == null) return;
    final dir = await _notesDir();
    final f = await File(img.path).copy(
      '${dir.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    setState(() => _imageFile = f);
  }

  Future<void> _pickVideo() async {
    if (!await _req(Permission.camera) || !await _req(Permission.microphone)) return;
    final vid = await ImagePicker().pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 3),
    );
    if (vid == null) return;
    final dir = await _notesDir();
    final f = await File(vid.path).copy(
      '${dir.path}/vid_${DateTime.now().millisecondsSinceEpoch}.mp4',
    );
    setState(() => _videoFile = f);
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // Stop and get file path
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        if (path != null) _audioPath = path;
      });
    } else {
      if (!await _req(Permission.microphone)) return;
      final dir = await _notesDir();
      final p = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // Start with RecordConfig
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: p,
      );
      setState(() => _isRecording = true);
    }
  }

  Future<void> _playPauseAudio() async {
    if (_playerState == PlayerState.playing) {
      await _player?.pause();
    } else {
      _player ??= AudioPlayer()
        ..onPlayerStateChanged.listen((s) {
          setState(() => _playerState = s);
        });
      if (_audioPath != null) {
        await _player!.play(DeviceFileSource(_audioPath!));
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final svc = OmniNoteService.instance;
    final editing = widget.omniNote != null;

    var note = editing
        ? (widget.omniNote!..title = _title)
        : OmniNote(
            title: _title,
            subtitle: _subtitle,
            content: _content,
            zone: _zone,
            tags: _customTags.join(','),
            attachments: [],
            mood: _mood,
            direction: _direction,
            projectId: _projectId,
            colorValue: _noteColor.value,
          );

    note
      ..subtitle = _subtitle
      ..content = _content
      ..zone = _zone
      ..tags = _customTags.join(',')
      ..mood = _mood
      ..direction = _direction
      ..projectId = _projectId
      ..colorValue = _noteColor.value
      ..recommendedTag = _pickedTags.isNotEmpty ? _pickedTags.first : null;

    if (editing) {
      await svc.updateNote(note);
    } else {
      await svc.createNote(note);
    }
    if (_imageFile != null) await svc.addImageAttachment(note, _imageFile!);
    if (_videoFile != null) await svc.addVideoAttachment(note, _videoFile!);
    if (_audioPath != null) await svc.addAudioAttachment(note, File(_audioPath!));

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _contentCtl.dispose();
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/journal_bg.png', fit: BoxFit.cover),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 80),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Header & close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.omniNote != null ? 'Edit Note' : 'New Note',
                        style: theme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Mode toggle
                  ToggleButtons(
                    isSelected: NoteMode.values.map((m) => m == _mode).toList(),
                    onPressed: (i) => setState(() => _mode = NoteMode.values[i]),
                    children: const [
                      Padding(padding: EdgeInsets.all(8), child: Icon(Icons.text_fields)),
                      Padding(padding: EdgeInsets.all(8), child: Icon(Icons.mic)),
                      Padding(padding: EdgeInsets.all(8), child: Icon(Icons.camera_alt)),
                      Padding(padding: EdgeInsets.all(8), child: Icon(Icons.videocam)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  if (_mode == NoteMode.text) _buildTextUI(),
                  if (_mode == NoteMode.voice) _buildVoiceUI(),
                  if (_mode == NoteMode.image) _buildImageUI(),
                  if (_mode == NoteMode.video) _buildVideoUI(),

                  const SizedBox(height: 24),
                  _buildMetaUI(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.save),
        label: const Text('Save'),
        onPressed: _save,
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  Widget _buildTextUI() => Column(
        children: [
          TextFormField(
            initialValue: _title,
            decoration: const InputDecoration(labelText: 'Title'),
            onChanged: (v) => _title = v,
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: _subtitle,
            decoration: const InputDecoration(labelText: 'Subtitle'),
            onChanged: (v) => _subtitle = v,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _contentCtl,
            decoration: const InputDecoration(
              labelText: 'Content',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            onChanged: (v) => _content = v,
          ),
          const SizedBox(height: 12),
          if (_isGenerating) const CircularProgressIndicator(),
          if (!_isGenerating && _aiTags.isNotEmpty)
            Wrap(
              spacing: 8,
              children: _aiTags.map((t) {
                final sel = _pickedTags.contains(t);
                return ChoiceChip(
                  label: Text(t),
                  selected: sel,
                  onSelected: (s) => setState(() {
                    if (s) _pickedTags.add(t);
                    else _pickedTags.remove(t);
                  }),
                );
              }).toList(),
            ),
        ],
      );

  Widget _buildVoiceUI() => Column(
        children: [
          if (_audioPath != null)
            Row(
              children: [
                IconButton(
                  icon: Icon(
                      _playerState == PlayerState.playing ? Icons.pause : Icons.play_arrow),
                  onPressed: _playPauseAudio,
                ),
                Text(_isRecording ? 'Recording...' : 'Playback'),
              ],
            ),
          ElevatedButton.icon(
            icon: Icon(_isRecording ? Icons.stop : Icons.mic),
            label: Text(_isRecording ? 'Stop Recording' : 'Record Audio'),
            onPressed: _toggleRecording,
          ),
        ],
      );

  Widget _buildImageUI() => Column(
        children: [
          if (_imageFile != null) Image.file(_imageFile!, height: 200),
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
            onPressed: _pickImage,
          ),
        ],
      );

  Widget _buildVideoUI() => Column(
        children: [
          if (_videoFile != null)
            Container(
              height: 200,
              color: Colors.black12,
              child: const Center(child: Icon(Icons.play_arrow, size: 48)),
            ),
          ElevatedButton.icon(
            icon: const Icon(Icons.videocam),
            label: const Text('Record Video'),
            onPressed: _pickVideo,
          ),
        ],
      );

  Widget _buildMetaUI() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Color'),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              Color temp = _noteColor;
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Select Color'),
                  content: ColorPicker(
                    pickerColor: _noteColor,
                    onColorChanged: (c) => temp = c,
                    showLabel: false,
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _noteColor = temp);
                        Navigator.pop(context);
                      },
                      child: const Text('Select'),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              height: 30,
              width: 60,
              decoration: BoxDecoration(
                color: _noteColor,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _mood,
            decoration: const InputDecoration(labelText: 'Mood'),
            onChanged: (v) => _mood = v,
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _direction,
            decoration: const InputDecoration(labelText: 'Direction'),
            onChanged: (v) => _direction = v,
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _projectId,
            decoration: const InputDecoration(labelText: 'Project'),
            onChanged: (v) => _projectId = v,
          ),
        ],
      );
}