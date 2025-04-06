import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'custom_notification_bar.dart';

class ImagePickerComponent extends StatefulWidget {
  final Function(int, File?) onImageSelected;
  final String heading;
  final File? initialImage;
  final int index;

  const ImagePickerComponent({
    super.key,
    required this.onImageSelected,
    required this.heading,
    required this.index,
    this.initialImage,
  });

  @override
  State<ImagePickerComponent> createState() => _ImagePickerComponentState();
}

class _ImagePickerComponentState extends State<ImagePickerComponent> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage;
  }

  Future<void> _pickImage(ImageSource source) async {
    var status = source == ImageSource.camera
        ? await Permission.camera.request()
        : await Permission.photos.request();

    if (status.isGranted) {
      final XFile? pickedImage = await _picker.pickImage(source: source);
      if (pickedImage != null) {
        setState(() {
          _selectedImage = File(pickedImage.path);
        });
        widget.onImageSelected(widget.index, _selectedImage);
      }
    } else {
      showCustomNotification(
          context,
          source == ImageSource.camera ? "Camera permission denied" : "Gallery permission denied",
          Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Full width
      height: 400, // Fixed height
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(12), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Subtle shadow
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(4, 4), // Shadow position
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center, // Center elements horizontally
        children: [
          Text(
            widget.heading,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          _selectedImage != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8), // Slightly rounded image corners
            child: Image.file(
              _selectedImage!,
              width: double.infinity, // Full width
              height: 250, // Fixed height
              fit: BoxFit.cover,
            ),
          )
              : Container(
            width: double.infinity, // Full width
            height: 250, // Fixed height
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image, size: 100, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
