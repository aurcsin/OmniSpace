import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/attachment.dart';
import '../widgets/main_menu_drawer.dart';
import '../widgets/photo_video_preview.dart';

/// Simple gallery page demonstrating photo and video picking.
class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  final List<Map<String, dynamic>> _items = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _items.add({'path': picked.path, 'type': AttachmentType.image});
      });
    }
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _items.add({'path': picked.path, 'type': AttachmentType.video});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media')),
      drawer: const MainMenuDrawer(),
      body: _items.isEmpty
          ? const Center(child: Text('No media selected'))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final item = _items[i];
                return PhotoVideoPreview(
                  path: item['path'] as String,
                  type: item['type'] as AttachmentType,
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'photo',
            onPressed: _pickImage,
            child: const Icon(Icons.photo),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'video',
            onPressed: _pickVideo,
            child: const Icon(Icons.videocam),
          ),
        ],
      ),
    );
  }
}
