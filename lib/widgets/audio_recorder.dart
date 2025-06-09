import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart' as rec;

/// Simple audio recorder widget using the `record` plugin.
/// When recording stops, [onRecorded] provides the resulting file.
class AudioRecorder extends StatefulWidget {
  final ValueChanged<File> onRecorded;
  const AudioRecorder({super.key, required this.onRecorded});

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  final rec.AudioRecorder _recorder = rec.AudioRecorder();
  bool _isRecording = false;

  Future<void> _toggle() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() => _isRecording = false);
      if (path != null) widget.onRecorded(File(path));
    } else {
      if (await _recorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final path =
            '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _recorder.start(
          rec.RecordConfig(
            encoder: rec.AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );
        setState(() => _isRecording = true);
      }
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: Icon(_isRecording ? Icons.stop : Icons.mic),
          label: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
          onPressed: _toggle,
        ),
      ],
    );
  }
}
