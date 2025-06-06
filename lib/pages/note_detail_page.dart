// lib/pages/note_detail_page.dart

import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';

import '../models/omni_note.dart';         // OmniNote, ZoneTheme
//import '../models/attachment.dart';        // AttachmentType
import '../models/task.dart';              // Task
import '../models/goal.dart';              // Goal
import '../models/event.dart';             // Event

import '../services/omni_note_service.dart';
import '../services/ai_service.dart';      // AIService.generateRecommendedTag

/// In this page you can switch between Text / Voice / Image / Video modes,
/// enter metadata (color, mood, direction, project), plus Tasks, Goals, Events.
enum NoteMode { text, voice, image, video }

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

  // ─── Common text fields ───────────────────────────────────────────────────────
  late String _title;
  late String _subtitle;
  late String _content;
  late ZoneTheme _selectedZone;
  String? _selectedRecommendedTag;
  List<String> _customTagList = [];
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();

  // ─── Metadata: color, mood, direction, project ───────────────────────────────
  Color _noteColor = Colors.white;
  String? _mood;
  String? _direction;
  String? _projectId;

  // ─── Mode state ────────────────────────────────────────────────────────────────
  late NoteMode _mode;

  // ─── AI tag generator ─────────────────────────────────────────────────────────
  bool _isGeneratingTag = false;
  List<String> _recommendedTagOptions = [];

  // ─── Image state ──────────────────────────────────────────────────────────────
  File? _pickedImageFile;
  bool _imageSaved = false;

  // ─── Audio state ──────────────────────────────────────────────────────────────
  File? _recordedAudioFile;
  bool _isRecording = false;
  Timer? _recordingTimer;
  int _secondsRecorded = 0;
  double _fakeAmplitude = 0.0;
  Timer? _amplitudeTimer;

  // ─── Video state ──────────────────────────────────────────────────────────────
  File? _pickedVideoFile;
  bool _videoSaved = false;

  // ─── Tasks / Goals / Events ───────────────────────────────────────────────────
  late List<Task> _tasks;     // from task.dart
  late List<Goal> _goals;     // from goal.dart
  late List<Event> _events;   // from event.dart

  @override
  void initState() {
    super.initState();

    _mode = widget.initialMode;

    if (widget.omniNote != null) {
      // Pre‐fill fields when editing
      final note = widget.omniNote!;
      _title = note.title;
      _subtitle = note.subtitle;
      _content = note.content;
      _selectedZone = note.zone;
      _selectedRecommendedTag = note.recommendedTag;
      _customTagList = note.tags.split(',').where((s) => s.isNotEmpty).toList();
      _contentController.text = _content;
      _tagsController.text = note.tags;

      _noteColor = Color(note.colorValue);
      _mood = note.mood;
      _direction = note.direction;
      _projectId = note.projectId;

      // If the Hive-backed OmniNote stored null for tasks/goals/events, treat as an empty list:
      _tasks = List.from(note.tasks ?? <Task>[]);
      _goals = List.from(note.goals ?? <Goal>[]);
      _events = List.from(note.events ?? <Event>[]);
    } else {
      // New-note defaults
      _title = '';
      _subtitle = '';
      _content = '';
      _selectedZone = ZoneTheme.Fusion;
      _selectedRecommendedTag = null;
      _customTagList = [];
      _noteColor = Colors.white;
      _mood = null;
      _direction = null;
      _projectId = null;
      _tasks = <Task>[];
      _goals = <Goal>[];
      _events = <Event>[];
    }

    // Whenever user types in Content (Text mode), ask AI for a tag if > 5 chars
    _contentController.addListener(() async {
      final text = _contentController.text.trim();
      if (_mode == NoteMode.text && text.length > 5) {
        setState(() => _isGeneratingTag = true);
        final aiTag = await AIService.instance.generateRecommendedTag(text);
        setState(() {
          _isGeneratingTag = false;
          _recommendedTagOptions = aiTag != null ? [aiTag] : [];
          if (widget.omniNote == null) {
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
    _recordingTimer?.cancel();
    _amplitudeTimer?.cancel();
    super.dispose();
  }

  /// Request a single permission (camera, microphone, etc.)
  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.request();
    return status == PermissionStatus.granted;
  }

  /// ─────────────────────────────────────────────────────────────────────────────
  /// Voice Handling: start/stop recording (simulated timer + fake amplitude)
  /// ─────────────────────────────────────────────────────────────────────────────
  Future<void> _startRecording() async {
    final micPerm = await _requestPermission(Permission.microphone);
    if (!micPerm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied.')),
      );
      return;
    }

    setState(() {
      _isRecording = true;
      _secondsRecorded = 0;
      _fakeAmplitude = 0.0;
      _recordedAudioFile = null;
      _imageSaved = false;
      _videoSaved = false;
    });

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsRecorded++;
      });
    });

    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {
        _fakeAmplitude = 5 + (5 * (DateTime.now().millisecond % 100) / 100);
      });
    });

    // In a real app, you’d call something like:
    // await _audioRecorder!.startRecorder(toFile: fullPath, codec: Codec.aacADTS);
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    _amplitudeTimer?.cancel();

    // For now, simulate a path:
    final docDir = await getApplicationDocumentsDirectory();
    final notesDir = Directory('${docDir.path}/notes');
    if (!await notesDir.exists()) {
      await notesDir.create(recursive: true);
    }
    final simulatedPath =
        '${notesDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

    setState(() {
      _isRecording = false;
      _recordedAudioFile = File(simulatedPath);
    });
  }

  /// ─────────────────────────────────────────────────────────────────────────────
  /// Image Handling: pick/capture and save into app folder
  /// ─────────────────────────────────────────────────────────────────────────────
  Future<void> _pickImage() async {
    final camPerm = await _requestPermission(Permission.camera);
    final galleryPerm = await _requestPermission(Permission.photos);
    if (!camPerm && !galleryPerm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera or gallery permission denied.')),
      );
      return;
    }

    final picked =
        await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
    if (picked == null) return;

    setState(() {
      _pickedImageFile = File(picked.path);
      _imageSaved = false;
    });

    final appDir = await getApplicationDocumentsDirectory();
    final notesDir = Directory('${appDir.path}/notes');
    if (!await notesDir.exists()) {
      await notesDir.create(recursive: true);
    }
    final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = await File(picked.path).copy('${notesDir.path}/$fileName');

    setState(() {
      _pickedImageFile = savedImage;
      _imageSaved = true;
    });
  }

  /// ─────────────────────────────────────────────────────────────────────────────
  /// Video Handling: pick/record and save into app folder
  /// ─────────────────────────────────────────────────────────────────────────────
  Future<void> _pickVideo() async {
    final camPerm = await _requestPermission(Permission.camera);
    final micPerm = await _requestPermission(Permission.microphone);
    if (!camPerm || !micPerm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera/microphone permission denied.')),
      );
      return;
    }

    final picked = await ImagePicker().pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 5),
    );
    if (picked == null) return;

    setState(() {
      _pickedVideoFile = null;
      _videoSaved = false;
    });

    final appDir = await getApplicationDocumentsDirectory();
    final notesDir = Directory('${appDir.path}/notes');
    if (!await notesDir.exists()) {
      await notesDir.create(recursive: true);
    }
    final fileName = 'vid_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final savedVideo = await File(picked.path).copy('${notesDir.path}/$fileName');

    setState(() {
      _pickedVideoFile = savedVideo;
      _videoSaved = true;
    });
  }

  /// ─────────────────────────────────────────────────────────────────────────────
  /// Save or Update the note, including attachments, media, and metadata
  /// ─────────────────────────────────────────────────────────────────────────────
  Future<void> _handleSave() async {
    final noteService = OmniNoteService.instance;
    final isEditing = widget.omniNote != null;

    // In Text mode, require at least title or content
    if (_mode == NoteMode.text &&
        _title.trim().isEmpty &&
        _content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a title or content before saving.')),
      );
      return;
    }

    if (isEditing) {
      final note = widget.omniNote!;
      note.title = _title;
      note.subtitle = _subtitle;
      note.content = _content;
      note.zone = _selectedZone;
      note.recommendedTag = _selectedRecommendedTag;
      note.tags = _customTagList.join(',');
      note.mood = _mood;
      note.direction = _direction;
      note.projectId = _projectId;
      note.colorValue = _noteColor.value;
      // If the lists are non-empty, store them; otherwise store null
      note.tasks = _tasks.isNotEmpty ? List.from(_tasks) : null;
      note.goals = _goals.isNotEmpty ? List.from(_goals) : null;
      note.events = _events.isNotEmpty ? List.from(_events) : null;

      if (_pickedImageFile != null && _imageSaved) {
        await noteService.addImageAttachment(note, _pickedImageFile!);
      }
      if (_recordedAudioFile != null) {
        await noteService.addAudioAttachment(note, _recordedAudioFile!);
      }
      if (_pickedVideoFile != null && _videoSaved) {
        await noteService.addVideoAttachment(note, _pickedVideoFile!);
      }

      await noteService.updateNote(note);
    } else {
      final newNote = OmniNote(
        title: _title,
        subtitle: _subtitle,
        content: _content,
        zone: _selectedZone,
        recommendedTag: _selectedRecommendedTag,
        tags: _customTagList.join(','),
        attachments: [],
        tasks: _tasks.isNotEmpty ? _tasks : null,
        goals: _goals.isNotEmpty ? _goals : null,
        events: _events.isNotEmpty ? _events : null,
        mood: _mood,
        direction: _direction,
        projectId: _projectId,
        colorValue: _noteColor.value,
      );
      await noteService.createNote(newNote);

      if (_pickedImageFile != null && _imageSaved) {
        await noteService.addImageAttachment(newNote, _pickedImageFile!);
      }
      if (_recordedAudioFile != null) {
        await noteService.addAudioAttachment(newNote, _recordedAudioFile!);
      }
      if (_pickedVideoFile != null && _videoSaved) {
        await noteService.addVideoAttachment(newNote, _pickedVideoFile!);
      }
    }

    Navigator.of(context).pop();
  }

  /// ─────────────────────────────────────────────────────────────────────────────
  /// Export stub: prints JSON to console (for future “OmniLink” sharing)
  /// ─────────────────────────────────────────────────────────────────────────────
  void _exportNote() {
    final note = widget.omniNote;
    if (note == null) return;

    final data = {
      'title': note.title,
      'subtitle': note.subtitle,
      'content': note.content,
      'zone': note.zone.toString(),
      'tags': note.tags,
      'createdAt': note.createdAt.toIso8601String(),
      'attachments': note.attachments
          .map((a) => {
                'type': a.type.toString().split('.').last,
                'path': a.localPath,
                'createdAt': a.createdAt.toIso8601String(),
              })
          .toList(),
      'tasks': note.tasks
          ?.map((t) => {'description': t.description, 'isCompleted': t.isCompleted})
          .toList(),
      'goals': note.goals
          ?.map((g) => {
                'title': g.title,
                'description': g.description,
                'progressNotes': g.progressNotes,
              })
          .toList(),
      'events': note.events
          ?.map((e) => {
                'title': e.title,
                'eventDate': e.eventDate.toIso8601String(),
                'isRecurring': e.isRecurring,
                'recurringRule': e.recurringRule,
              })
          .toList(),
      'mood': note.mood,
      'direction': note.direction,
      'projectId': note.projectId,
      'color': note.colorValue,
      'starred': note.starred,
      'pinned': note.pinned,
      'archived': note.archived,
      'isPrivate': note.isPrivate,
    };

    debugPrint('[Export] $data');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note exported to console (debugPrint).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.omniNote != null;
    final note = widget.omniNote;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'New Note'),
        actions: [
          if (isEditing) ...[
            IconButton(
              icon: Icon(note!.starred ? Icons.star : Icons.star_border_outlined),
              onPressed: () {
                OmniNoteService.instance.toggleStar(note);
              },
            ),
            IconButton(
              icon: Icon(note.pinned ? Icons.push_pin : Icons.push_pin_outlined),
              onPressed: () {
                OmniNoteService.instance.togglePin(note);
              },
            ),
            IconButton(
              icon: Icon(note.isPrivate ? Icons.lock : Icons.lock_open_outlined),
              onPressed: () {
                OmniNoteService.instance.togglePrivacy(note);
              },
            ),
            IconButton(
              icon: const Icon(Icons.archive),
              onPressed: () {
                OmniNoteService.instance.archiveNote(note);
                Navigator.of(context).pop();
              },
            ),
            IconButton(icon: const Icon(Icons.share), onPressed: _exportNote),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await OmniNoteService.instance.deleteNote(note);
                Navigator.of(context).pop();
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // Nothing to share if note not yet saved
              },
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Mode toggle (Text / Voice / Image / Video) ───────────────────────────
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
                      NoteMode.video,
                    ][idx];
                    _resetMediaState();
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(children: [Icon(Icons.text_fields), Text('Text')]),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(children: [Icon(Icons.mic), Text('Voice')]),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(children: [Icon(Icons.camera_alt), Text('Image')]),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(children: [Icon(Icons.videocam), Text('Video')]),
                  ),
                ],
              ),
            ),
            const Divider(),

            // ── Mode-specific UI ─────────────────────────────────────────────────────
            if (_mode == NoteMode.text)
              _buildTextUI()
            else if (_mode == NoteMode.voice)
              _buildVoiceUI()
            else if (_mode == NoteMode.image)
              _buildImageUI()
            else
              _buildVideoUI(),

            const SizedBox(height: 20),

            // ── Media-Independent Metadata: Color, Mood, Direction, Project ────────
            _buildMediaIndependentFields(),

            const SizedBox(height: 20),

            // ── Zone + Save/Update Button ────────────────────────────────────────────
            _buildCommonFields(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Clear any media “preview” state when switching modes
  void _resetMediaState() {
    _pickedImageFile = null;
    _imageSaved = false;
    _recordedAudioFile = null;
    _isRecording = false;
    _secondsRecorded = 0;
    _fakeAmplitude = 0.0;
    _pickedVideoFile = null;
    _videoSaved = false;
  }

  /// ─────────────────────────────────────────────────────────────────────────────
  /// Voice UI: Timer, amplitude bar, and record/stop button
  /// ─────────────────────────────────────────────────────────────────────────────
  Widget _buildVoiceUI() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(_secondsRecorded ~/ 60);
    final seconds = twoDigits(_secondsRecorded % 60);

    return Column(
      children: [
        const SizedBox(height: 16),
        if (_recordedAudioFile == null)
          const Text(
            'Tap the mic below to record a voice note',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          )
        else
          Column(
            children: [
              const Icon(Icons.mic, size: 60, color: Colors.redAccent),
              const SizedBox(height: 8),
              Text('Recorded: $minutes:$seconds'),
            ],
          ),
        const SizedBox(height: 12),
        if (_isRecording) ...[
          // A rudimentary “amplitude” bar for visual feedback
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: LinearProgressIndicator(
              value: (_fakeAmplitude % 10) / 10,
            ),
          ),
          const SizedBox(height: 8),
          Text('Recording: $minutes:$seconds'),
        ],
        const SizedBox(height: 12),
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

  /// ─────────────────────────────────────────────────────────────────────────────
  /// Image UI: Preview + status (“saving…” or “saved”)
  /// ─────────────────────────────────────────────────────────────────────────────
  Widget _buildImageUI() {
    return Column(
      children: [
        const SizedBox(height: 16),
        if (_pickedImageFile == null)
          const Text(
            'Tap the camera below to capture/upload an image',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Image.file(
              _pickedImageFile!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _imageSaved ? 'Image saved ✓' : 'Saving image...',
            style: TextStyle(
              color: _imageSaved ? Colors.green : Colors.grey.shade700,
            ),
          ),
        ],
        const SizedBox(height: 12),
        FloatingActionButton(
          backgroundColor: Colors.teal,
          child: const Icon(Icons.camera_alt),
          onPressed: _pickImage,
        ),
      ],
    );
  }

  /// ─────────────────────────────────────────────────────────────────────────────
  /// Text UI: Title, Subtitle, Content (optional), AI-generated tag, manual Tags,
  /// plus Tasks / Goals / Events subsections
  /// ─────────────────────────────────────────────────────────────────────────────
  Widget _buildTextUI() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            // Title (optional)
            TextFormField(
              initialValue: _title,
              decoration: const InputDecoration(labelText: 'Title (optional)'),
              onChanged: (val) => _title = val.trim(),
            ),
            const SizedBox(height: 12),

            // Subtitle (optional)
            TextFormField(
              initialValue: _subtitle,
              decoration: const InputDecoration(labelText: 'Subtitle (optional)'),
              onChanged: (val) => _subtitle = val.trim(),
            ),
            const SizedBox(height: 12),

            // Content (optional)
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content (optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              minLines: 4,
              onChanged: (val) => _content = val.trim(),
            ),
            const SizedBox(height: 12),

            // Recommended Tag (AI-generated)
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Recommended Tag (optional)',
                border: UnderlineInputBorder(),
              ),
              child: _isGeneratingTag
                  ? Row(
                      children: const [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 8),
                        Text('Generating…'),
                      ],
                    )
                  : (_recommendedTagOptions.isEmpty
                      ? Text(
                          widget.omniNote != null && _selectedRecommendedTag != null
                              ? _selectedRecommendedTag!
                              : '—',
                          style: const TextStyle(color: Colors.grey),
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
                            onChanged: (val) => setState(() => _selectedRecommendedTag = val),
                          ),
                        )),
            ),
            const SizedBox(height: 12),

            // Custom Tags (comma-separated, optional)
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma-separated, optional)',
                border: UnderlineInputBorder(),
                hintText: 'e.g. #work, mood:productive',
              ),
              onChanged: (val) {
                final parts = val.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                setState(() => _customTagList = parts);
              },
            ),
            const SizedBox(height: 12),

            // ── Tasks Section ─────────────────────────────────────────────────────
            _buildTasksUI(),

            // ── Goals Section ─────────────────────────────────────────────────────
            _buildGoalsUI(),

            // ── Events Section ───────────────────────────────────────────────────
            _buildEventsUI(),
          ],
        ),
      ),
    );
  }

  /// ─────────────────────────────────────────────────────────────────────────────
  /// Video UI: Preview placeholder + status (“saving…” or “saved”)
  /// ─────────────────────────────────────────────────────────────────────────────
  Widget _buildVideoUI() {
    return Column(
      children: [
        const SizedBox(height: 16),
        if (_pickedVideoFile == null)
          const Text(
            'Tap the camera below to record/upload a video',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              height: 200,
              color: Colors.black12,
              child: const Center(child: Icon(Icons.play_arrow, size: 48, color: Colors.black54)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _videoSaved ? 'Video saved ✓' : 'Saving video...',
            style: TextStyle(color: _videoSaved ? Colors.green : Colors.grey.shade700),
          ),
        ],
        const SizedBox(height: 12),
        FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.videocam),
          onPressed: _pickVideo,
        ),
      ],
    );
  }

  /// ─────────────────────────────────────────────────────────────────────────────
  /// Tasks UI: vertical list of checkboxes + “Add Task” button
  /// ─────────────────────────────────────────────────────────────────────────────
  Widget _buildTasksUI() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
          ..._tasks.map((task) {
            return CheckboxListTile(
              value: task.isCompleted,
              title: Text(task.description),
              onChanged: (val) {
                setState(() {
                  task.isCompleted = val ?? false;
                });
              },
              secondary: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _tasks.remove(task);
                  });
                },
              ),
            );
          }).toList(),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
            onPressed: _showAddTaskDialog,
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    String desc = '';
    String? rule;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (val) => desc = val.trim(),
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Recurring'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('No')),
                  DropdownMenuItem(value: 'DAILY', child: Text('Daily')),
                  DropdownMenuItem(value: 'WEEKLY', child: Text('Weekly')),
                  DropdownMenuItem(value: 'MONTHLY', child: Text('Monthly')),
                ],
                onChanged: (val) => rule = val,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                if (desc.isNotEmpty) {
                  final task = Task(description: desc, recurringRule: rule);
                  setState(() {
                    _tasks.add(task);
                  });
                }
                Navigator.of(ctx).pop();
              },
              child: const Text('ADD'),
            ),
          ],
        );
      },
    );
  }

  /// ─────────────────────────────────────────────────────────────────────────────
  /// Goals UI: expandable list of goals, each with progress notes + “Add Progress”
  /// ─────────────────────────────────────────────────────────────────────────────
  Widget _buildGoalsUI() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Goals', style: TextStyle(fontWeight: FontWeight.bold)),
          ..._goals.map((goal) {
            return ExpansionTile(
              title: Text(goal.title),
              subtitle: goal.description != null ? Text(goal.description!) : null,
              children: [
                ...goal.progressNotes.map((note) => ListTile(title: Text(note))).toList(),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Progress'),
                  onPressed: () {
                    _showAddProgressDialog(goal);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _goals.remove(goal);
                    });
                  },
                ),
              ],
            );
          }).toList(),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Goal'),
            onPressed: _showAddGoalDialog,
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog() {
    String title = '';
    String desc = '';
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('New Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (val) => title = val.trim(),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Description (optional)'),
                onChanged: (val) => desc = val.trim(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                if (title.isNotEmpty) {
                  final goal = Goal(title: title, description: desc.isEmpty ? null : desc);
                  setState(() {
                    _goals.add(goal);
                  });
                }
                Navigator.of(ctx).pop();
              },
              child: const Text('ADD'),
            ),
          ],
        );
      },
    );
  }

  void _showAddProgressDialog(Goal goal) {
    String progress = '';
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Progress'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Progress'),
            onChanged: (val) => progress = val.trim(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                if (progress.isNotEmpty) {
                  setState(() {
                    goal.progressNotes.add(progress);
                  });
                }
                Navigator.of(ctx).pop();
              },
              child: const Text('ADD'),
            ),
          ],
        );
      },
    );
  }

  /// ─────────────────────────────────────────────────────────────────────────────
  /// Events UI: list of one-time or recurring events + “Add Event” button
  /// ─────────────────────────────────────────────────────────────────────────────
  Widget _buildEventsUI() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Events', style: TextStyle(fontWeight: FontWeight.bold)),
          ..._events.map((ev) {
            return ListTile(
              title: Text(ev.title),
              subtitle: Text(
                DateFormat.yMMMd().format(ev.eventDate) +
                    (ev.isRecurring ? ' (Recurring: ${ev.recurringRule})' : ''),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _events.remove(ev);
                  });
                },
              ),
            );
          }).toList(),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Event'),
            onPressed: _showAddEventDialog,
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog() {
    String title = '';
    DateTime? chosenDate;
    bool isRecurring = false;
    String? recurringRule;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('New Event'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Title'),
                  onChanged: (val) => title = val.trim(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      chosenDate == null
                          ? 'No date chosen'
                          : DateFormat.yMMMd().format(chosenDate!),
                    ),
                    const Spacer(),
                    TextButton(
                      child: const Text('Pick Date'),
                      onPressed: () async {
                        final dt = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                        );
                        if (dt != null) setDialogState(() => chosenDate = dt);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: isRecurring,
                      onChanged: (val) {
                        setDialogState(() => isRecurring = val ?? false);
                      },
                    ),
                    const Text('Recurring?'),
                  ],
                ),
                if (isRecurring)
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Rule'),
                    items: const [
                      DropdownMenuItem(value: 'DAILY', child: Text('Daily')),
                      DropdownMenuItem(value: 'WEEKLY', child: Text('Weekly')),
                      DropdownMenuItem(value: 'MONTHLY', child: Text('Monthly')),
                    ],
                    onChanged: (val) => setDialogState(() => recurringRule = val),
                  ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('CANCEL')),
              ElevatedButton(
                onPressed: () {
                  if (title.isNotEmpty && chosenDate != null) {
                    final ev = Event(
                      title: title,
                      eventDate: chosenDate!,
                      isRecurring: isRecurring,
                      recurringRule: recurringRule,
                    );
                    setState(() {
                      _events.add(ev);
                    });
                  }
                  Navigator.of(ctx).pop();
                },
                child: const Text('ADD'),
              ),
            ],
          );
        });
      },
    );
  }

  /// ─────────────────────────────────────────────────────────────────────────────
  /// Media-Independent Metadata: Color, Mood, Direction, Project
  /// ─────────────────────────────────────────────────────────────────────────────
  Widget _buildMediaIndependentFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color picker
          const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _showColorPicker,
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                color: _noteColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade400),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Mood
          TextFormField(
            initialValue: _mood,
            decoration: const InputDecoration(
              labelText: 'Mood (optional)',
              border: UnderlineInputBorder(),
            ),
            onChanged: (val) => setState(() => _mood = val.trim()),
          ),
          const SizedBox(height: 16),

          // Direction
          TextFormField(
            initialValue: _direction,
            decoration: const InputDecoration(
              labelText: 'Direction (optional)',
              border: UnderlineInputBorder(),
            ),
            onChanged: (val) => setState(() => _direction = val.trim()),
          ),
          const SizedBox(height: 16),

          // Project
          TextFormField(
            initialValue: _projectId,
            decoration: const InputDecoration(
              labelText: 'Project (optional)',
              border: UnderlineInputBorder(),
            ),
            onChanged: (val) => setState(() => _projectId = val.trim()),
          ),
        ],
      ),
    );
  }

  void _showColorPicker() {
    Color temp = _noteColor;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Select Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _noteColor,
              onColorChanged: (c) => temp = c,
              showLabel: false,
              pickerAreaHeightPercent: 0.7,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                setState(() => _noteColor = temp);
                Navigator.of(ctx).pop();
              },
              child: const Text('SELECT'),
            ),
          ],
        );
      },
    );
  }

  /// ─────────────────────────────────────────────────────────────────────────────
  /// Common Fields: Zone dropdown + Save/Update button
  /// ─────────────────────────────────────────────────────────────────────────────
  Widget _buildCommonFields() {
    final isEditing = widget.omniNote != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<ZoneTheme>(
            decoration: const InputDecoration(
              labelText: 'Zone Theme',
              border: UnderlineInputBorder(),
            ),
            value: _selectedZone,
            items: ZoneTheme.values
                .map((zone) => DropdownMenuItem(
                      value: zone,
                      child: Text(_formatZone(zone)),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedZone = val);
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _handleSave,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(isEditing ? 'Update' : 'Save', style: const TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

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
