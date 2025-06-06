// lib/pages/note_detail_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/omni_note.dart';      // For OmniNote, ZoneTheme
import '../services/omni_note_service.dart';
import '../services/ai_service.dart';   // For AIService.generateRecommendedTag

enum NoteMode { voice, image, text, video }

class NoteDetailPage extends StatefulWidget {
  final OmniNote? omniNote;
  final NoteMode initialMode;

  const NoteDetailPage({
    Key? key,
    this.omniNote,
    this.initialMode = NoteMode.text,
  }) : super(key: key);

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final _formKey = GlobalKey<FormState>();

  // Common text fields
  late String _title;
  late String _subtitle;
  late String _content;
  late ZoneTheme _selectedZone;
  String? _selectedRecommendedTag;
  List<String> _customTagList = [];
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();

  // Mode (voice, image, text, video)
  late NoteMode _mode;

  // For “Text” mode (AI tag generation)
  bool _isGeneratingTag = false;
  List<String> _recommendedTagOptions = [];

  // For “Image” mode
  File? _pickedImageFile;

  // For “Audio” mode
  File? _recordedAudioFile;
  bool _isRecording = false;

  // For “Video” mode
  File? _pickedVideoFile;

  @override
  void initState() {
    super.initState();

    _mode = widget.initialMode;

    if (widget.omniNote != null) {
      // Editing an existing note
      final note = widget.omniNote!;
      _title = note.title;
      _subtitle = note.subtitle;
      _content = note.content;
      _selectedZone = note.zone;
      _selectedRecommendedTag = note.recommendedTag;
      _customTagList = note.tags.split(',').where((s) => s.isNotEmpty).toList();
      _contentController.text = _content;
      _tagsController.text = note.tags;
    } else {
      // Creating a new note
      _title = '';
      _subtitle = '';
      _content = '';
      _selectedZone = ZoneTheme.Fusion;
      _selectedRecommendedTag = null;
      _customTagList = [];
    }

    // Listen for content changes to generate AI tags (text mode only)
    _contentController.addListener(() async {
      final text = _contentController.text.trim();
      if (_mode == NoteMode.text && text.length > 5) {
        setState(() => _isGeneratingTag = true);
        final aiTag = await AIService.instance.generateRecommendedTag(text);
        setState(() {
          _isGeneratingTag = false;
          _recommendedTagOptions = aiTag != null ? [aiTag] : [];
          if (widget.omniNote == null) {
            // For new note, auto-select the generated tag
            _selectedRecommendedTag = aiTag;
          }
        });
      } else if (widget.omniNote == null && _mode == NoteMode.text) {
        setState(() {
          _recommendedTagOptions = [];
          _selectedRecommendedTag = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  // Request a single permission; return true if granted.
  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.request();
    return status == PermissionStatus.granted;
  }

  /// Pick or capture an image from camera/gallery
  Future<void> _pickImage() async {
    final camPerm = await _requestPermission(Permission.camera);
    final galleryPerm = await _requestPermission(Permission.photos);
    if (!camPerm && !galleryPerm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera or gallery permission denied.')),
      );
      return;
    }

    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() {
      _pickedImageFile = File(picked.path);
    });
  }

  /// Start voice recording (simulated for demo purposes)
  Future<void> _startRecording() async {
    final micPerm = await _requestPermission(Permission.microphone);
    if (!micPerm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Microphone permission denied.')),
      );
      return;
    }

    setState(() {
      _isRecording = true;
    });

    // Real implementation would start an audio recorder:
    // final docDir = await getApplicationDocumentsDirectory();
    // final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    // await _audioRecorder!.startRecorder(toFile: '$docDir/notes/$fileName');
  }

  /// Stop voice recording (simulated path)
  Future<void> _stopRecording() async {
    // In real code, capture recorder output path:
    // final recordedPath = await _audioRecorder!.stopRecorder();

    // Simulate a file path under app documents:
    final docDir = await getApplicationDocumentsDirectory();
    final notesDir = Directory('${docDir.path}/notes');
    if (!await notesDir.exists()) {
      await notesDir.create(recursive: true);
    }
    final simulatedPath = '${notesDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

    setState(() {
      _isRecording = false;
      _recordedAudioFile = File(simulatedPath);
    });
  }

  /// Pick or record a video (up to 5 minutes)
  Future<void> _pickVideo() async {
    final camPerm = await _requestPermission(Permission.camera);
    final micPerm = await _requestPermission(Permission.microphone);
    if (!camPerm || !micPerm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera/microphone permission denied.')),
      );
      return;
    }

    final picked = await ImagePicker().pickVideo(
      source: ImageSource.camera,
      maxDuration: Duration(minutes: 5),
    );
    if (picked == null) return;

    final docDir = await getApplicationDocumentsDirectory();
    final notesDir = Directory('${docDir.path}/notes');
    if (!await notesDir.exists()) {
      await notesDir.create(recursive: true);
    }

    final fileName = 'vid_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final savedVideo = await File(picked.path).copy('${notesDir.path}/$fileName');

    setState(() {
      _pickedVideoFile = savedVideo;
    });
  }

  /// Save or update the note
  Future<void> _handleSave() async {
    final noteService = OmniNoteService.instance;
    final isEditing = widget.omniNote != null;

    // If in Text mode, validate form
    if (_mode == NoteMode.text && !_formKey.currentState!.validate()) {
      return;
    }

    if (isEditing) {
      final note = widget.omniNote!;

      // Update fields
      note.title = _title;
      note.subtitle = _subtitle;
      note.content = _content;
      note.zone = _selectedZone;
      note.recommendedTag = _selectedRecommendedTag;
      note.tags = _customTagList.join(',');

      // Add new attachments if any
      if (_pickedImageFile != null) {
        await noteService.addImageAttachment(note, _pickedImageFile!);
      }
      if (_recordedAudioFile != null) {
        await noteService.addAudioAttachment(note, _recordedAudioFile!);
      }
      if (_pickedVideoFile != null) {
        await noteService.addVideoAttachment(note, _pickedVideoFile!);
      }

      // Save the updated note
      await noteService.updateNote(note);
    } else {
      // Create a new note
      final newNote = OmniNote(
        title: _title,
        subtitle: _subtitle,
        content: _content,
        zone: _selectedZone,
        recommendedTag: _selectedRecommendedTag,
        tags: _customTagList.join(','),
        attachments: [],
      );
      await noteService.createNote(newNote);

      if (_pickedImageFile != null) {
        await noteService.addImageAttachment(newNote, _pickedImageFile!);
      }
      if (_recordedAudioFile != null) {
        await noteService.addAudioAttachment(newNote, _recordedAudioFile!);
      }
      if (_pickedVideoFile != null) {
        await noteService.addVideoAttachment(newNote, _pickedVideoFile!);
      }
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.omniNote != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'New Note'),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await OmniNoteService.instance.deleteNote(widget.omniNote!);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1) Mode toggle: Text / Voice / Image / Video
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ToggleButtons(
                isSelected: [
                  _mode == NoteMode.text,
                  _mode == NoteMode.voice,
                  _mode == NoteMode.image,
                  _mode == NoteMode.video,
                ],
                onPressed: (idx) {
                  setState(() {
                    _mode = [
                      NoteMode.text,
                      NoteMode.voice,
                      NoteMode.image,
                      NoteMode.video
                    ][idx];
                  });
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [Icon(Icons.text_fields), Text('Text')]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [Icon(Icons.mic), Text('Voice')]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [Icon(Icons.camera_alt), Text('Image')]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [Icon(Icons.videocam), Text('Video')]),
                  ),
                ],
              ),
            ),
            Divider(),

            // 2) Mode‐specific UI
            if (_mode == NoteMode.text)
              _buildTextUI()
            else if (_mode == NoteMode.voice)
              _buildVoiceUI()
            else if (_mode == NoteMode.image)
              _buildImageUI()
            else
              _buildVideoUI(),

            SizedBox(height: 20),

            // 3) Common fields: Zone dropdown + Save button
            _buildCommonFields(),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// ---------------- Voice UI ----------------
  Widget _buildVoiceUI() {
    return Column(
      children: [
        SizedBox(height: 16),
        if (_recordedAudioFile == null)
          Text(
            'Tap the mic below to record a voice note',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                Icon(Icons.mic, size: 60, color: Colors.redAccent),
                SizedBox(height: 8),
                Text('Audio recorded and ready'),
              ],
            ),
          ),
        SizedBox(height: 12),
        FloatingActionButton(
          backgroundColor: _isRecording ? Colors.red : Colors.green,
          child: Icon(_isRecording ? Icons.stop : Icons.mic),
          onPressed: () {
            if (_isRecording) {
              _stopRecording();
            } else {
              _startRecording();
            }
          },
        ),
      ],
    );
  }

  /// ---------------- Image UI ----------------
  Widget _buildImageUI() {
    return Column(
      children: [
        SizedBox(height: 16),
        if (_pickedImageFile == null)
          Text(
            'Tap the camera below to capture/upload an image',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Image.file(
              _pickedImageFile!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
            ),
          ),
        SizedBox(height: 12),
        FloatingActionButton(
          backgroundColor: Colors.teal,
          child: Icon(Icons.camera_alt),
          onPressed: _pickImage,
        ),
      ],
    );
  }

  /// ---------------- Text UI ----------------
  Widget _buildTextUI() {
    final isEditing = widget.omniNote != null;

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            // Title field
            TextFormField(
              initialValue: _title,
              decoration: InputDecoration(labelText: 'Title'),
              onChanged: (val) => _title = val.trim(),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            SizedBox(height: 12),

            // Subtitle field
            TextFormField(
              initialValue: _subtitle,
              decoration: InputDecoration(labelText: 'Subtitle (optional)'),
              onChanged: (val) => _subtitle = val.trim(),
            ),
            SizedBox(height: 12),

            // Content field
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              minLines: 4,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter some content';
                }
                return null;
              },
              onChanged: (val) => _content = val.trim(),
            ),
            SizedBox(height: 12),

            // Recommended Tag (AI-generated)
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Recommended Tag',
                border: UnderlineInputBorder(),
              ),
              child: _isGeneratingTag
                  ? Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Generating…'),
                      ],
                    )
                  : (_recommendedTagOptions.isEmpty
                      ? Text(
                          isEditing && _selectedRecommendedTag != null
                              ? _selectedRecommendedTag!
                              : '–',
                          style: TextStyle(color: Colors.grey[600]),
                        )
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedRecommendedTag,
                            isDense: true,
                            items: _recommendedTagOptions.map((tag) {
                              return DropdownMenuItem(
                                value: tag,
                                child: Text(tag),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() {
                              _selectedRecommendedTag = val;
                            }),
                          ),
                        )),
            ),
            SizedBox(height: 12),

            // Custom Tags (comma-separated)
            TextFormField(
              controller: _tagsController,
              decoration: InputDecoration(
                labelText: 'Tags (comma-separated)',
                border: UnderlineInputBorder(),
                hintText: 'e.g. mood:happy, #travel',
              ),
              onChanged: (val) {
                final parts = val
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();
                setState(() => _customTagList = parts);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- Video UI ----------------
  Widget _buildVideoUI() {
    return Column(
      children: [
        SizedBox(height: 16),
        if (_pickedVideoFile == null)
          Text(
            'Tap the camera below to record/upload a video',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              height: 200,
              color: Colors.black12,
              child: Center(
                child: Icon(Icons.play_arrow, size: 48, color: Colors.black54),
              ),
            ),
          ),
        SizedBox(height: 12),
        FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.videocam),
          onPressed: _pickVideo,
        ),
      ],
    );
  }

  /// ---------------- Common Fields (Zone dropdown + Save) ----------------
  Widget _buildCommonFields() {
    final isEditing = widget.omniNote != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Zone Theme dropdown
          DropdownButtonFormField<ZoneTheme>(
            decoration: InputDecoration(
              labelText: 'Zone Theme',
              border: UnderlineInputBorder(),
            ),
            value: _selectedZone,
            items: ZoneTheme.values.map((zone) {
              return DropdownMenuItem(
                value: zone,
                child: Text(_formatZone(zone)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedZone = val);
            },
          ),
          SizedBox(height: 20),

          // Save/Update button
          ElevatedButton(
            onPressed: _handleSave,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                isEditing ? 'Update' : 'Save',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to convert a ZoneTheme enum into user‐friendly text
  String _formatZone(ZoneTheme zone) {
    switch (zone) {
      case ZoneTheme.Air:
        return 'Air (Sky)';
      case ZoneTheme.Earth:
        return 'Earth (Garden)';
      case ZoneTheme.Fire:
        return 'Fire (Workshop)';
      case ZoneTheme.Water:
        return 'Water (Studio)';
      case ZoneTheme.Void:
        return 'Void (Root Cave)';
      case ZoneTheme.Fusion:
        return 'Fusion (Journal)';
    }
  }
}
