import 'dart:io';
import 'package:client_portal/utils/blink_capture_camera.dart';
import 'package:flutter/material.dart';
import 'image_picker_component.dart'; // Ensure correct import

class NidImagePickerSlider extends StatefulWidget {
  final List<String> headings;
  final List<File?> photos; // Separate photos list passed from parent
  final Function(List<File?>) onImagesSelected;

  const NidImagePickerSlider({
    super.key,
    required this.headings,
    required this.photos,
    required this.onImagesSelected,
  });

  @override
  _NidImagePickerSliderState createState() =>
      _NidImagePickerSliderState();
}

class _NidImagePickerSliderState extends State<NidImagePickerSlider> {
  final PageController _pageController = PageController();
  late List<File?> selectedImages; // Independent state for selected images
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Initialize selectedImages with a fresh copy of the photos list from parent
    selectedImages = List.from(widget.photos);

    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  // Update the selected image and notify parent
  void _onImageSelected(int index, File? selectedImage) {
    setState(() {
      selectedImages[index] = selectedImage; // Update the selected image at the specified index
    });

    // Move to the next page if not the last image
    if (index < widget.headings.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    // Notify the parent widget of the updated images
    widget.onImagesSelected(selectedImages);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PageView for image picking
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 400,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.headings.length,
                itemBuilder: (context, index) {
                  return  index == 2 ? BlinkCaptureCamera(
                    heading: widget.headings[index],
                    index: index, // Pass index to track which image is selected
                    initialImage: selectedImages[index],
                    onImageSelected: _onImageSelected, // Pass the callback to update state
                  )
                      : ImagePickerComponent(
                    heading: widget.headings[index],
                    index: index, // Pass index to track which image is selected
                    initialImage: selectedImages[index], // Pass the current selected image
                    onImageSelected: _onImageSelected, // Pass the callback to update state
                  );
                },
              ),
            ),
            if (widget.headings.length > 1 && currentPage > 0)
              Positioned(
                left: 10,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            if (widget.headings.length > 1 && currentPage < widget.headings.length - 1)
              Positioned(
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.arrow_forward_ios, color: Colors.black),
                  onPressed: () {
                    if (_pageController.page! < widget.headings.length - 1) {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
          ],
        ),
        // Thumbnails for quick navigation between images
        Padding(
          padding: const EdgeInsets.only(top: 20), // Added top spacing
          child: Wrap(
            spacing: 10,
            runSpacing: 10, // Ensures proper spacing in multiple rows
            alignment: WrapAlignment.center, // Centers the images/icons
            children: List.generate(widget.headings.length, (index) {
              return GestureDetector(
                onTap: () {
                  _pageController.jumpToPage(index); // Jump to the clicked image
                },
                child: selectedImages[index] != null
                    ? Image.file(
                  selectedImages[index]!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
                    : const Icon(Icons.image, size: 50, color: Colors.grey),
              );
            }),
          ),
        ),
      ],
    );
  }
}
