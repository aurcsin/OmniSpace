// lib/widgets/photo_video_preview.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/attachment.dart';

/// Simple widget that displays either a photo or a video based on
/// [type]. For [AttachmentType.image] it shows the image file. For
/// [AttachmentType.video] it plays the video in a loop.
class PhotoVideoPreview extends StatefulWidget {
  final String path;
  final AttachmentType type;
  final double height;

  const PhotoVideoPreview({
    super.key,
    required this.path,
    required this.type,
    this.height = 200,
  });

  @override
  State<PhotoVideoPreview> createState() => _PhotoVideoPreviewState();
}

class _PhotoVideoPreviewState extends State<PhotoVideoPreview> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.type == AttachmentType.video) {
      _controller = VideoPlayerController.file(File(widget.path))
        ..setLooping(true)
        ..initialize().then((_) {
          if (mounted) setState(() {});
          _controller?.play();
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == AttachmentType.image) {
      return Image.file(
        File(widget.path),
        height: widget.height,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: widget.height,
      child: VideoPlayer(_controller!),
    );
  }
}
