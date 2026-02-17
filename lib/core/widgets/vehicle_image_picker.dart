import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// A reusable widget for vehicle image selection with camera/gallery options
/// Supports multiple images for vehicle documentation
class VehicleImagePicker extends StatefulWidget {
  final List<String>? currentImageUrls;
  final String vehiclePlate;
  final int maxImages;
  final ValueChanged<List<File>> onImagesSelected;
  final ValueChanged<List<String>>? onExistingImagesChanged;

  const VehicleImagePicker({
    super.key,
    this.currentImageUrls,
    required this.vehiclePlate,
    this.maxImages = 4,
    required this.onImagesSelected,
    this.onExistingImagesChanged,
  });

  @override
  State<VehicleImagePicker> createState() => _VehicleImagePickerState();
}

class _VehicleImagePickerState extends State<VehicleImagePicker> {
  final List<File> _selectedImages = [];
  late List<String> _remainingUrls;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _remainingUrls = List.from(widget.currentImageUrls ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Vehicle Photos',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${_selectedImages.length + _remainingUrls.length}/${widget.maxImages}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Add photos of your vehicle (front, back, sides, interior)',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add Photo Button
              if (_selectedImages.length + _remainingUrls.length <
                  widget.maxImages)
                _AddPhotoButton(onTap: _showImageSourceDialog),

              // Selected Images
              ..._selectedImages.asMap().entries.map((entry) {
                return _ImageTile(
                  image: entry.value,
                  onRemove: () => _removeImage(entry.key),
                );
              }),

              // Existing Network Images
              ..._remainingUrls.asMap().entries.map((entry) {
                return _NetworkImageTile(
                  url: entry.value,
                  onRemove: () => _removeExistingImage(entry.key),
                );
              }),
            ],
          ),
        ),

        // Quick Photo Buttons
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _QuickPhotoChip(
              label: 'Front View',
              icon: Icons.arrow_upward,
              onTap: () => _pickImage(ImageSource.camera),
            ),
            _QuickPhotoChip(
              label: 'Side View',
              icon: Icons.arrow_forward,
              onTap: () => _pickImage(ImageSource.camera),
            ),
            _QuickPhotoChip(
              label: 'Interior',
              icon: Icons.airline_seat_recline_normal,
              onTap: () => _pickImage(ImageSource.camera),
            ),
            _QuickPhotoChip(
              label: 'Documents',
              icon: Icons.description,
              onTap: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ],
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add Vehicle Photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.vehiclePlate,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _ImageSourceOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      _pickMultipleImages();
                    },
                  ),
                  if (_selectedImages.isNotEmpty)
                    _ImageSourceOption(
                      icon: Icons.delete_sweep,
                      label: 'Clear All',
                      color: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        _clearAllImages();
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length + _remainingUrls.length >= widget.maxImages) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Maximum ${widget.maxImages} images allowed')),
        );
      }
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(File(pickedFile.path));
        });
        widget.onImagesSelected(_selectedImages);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  Future<void> _pickMultipleImages() async {
    final remainingCount =
        widget.maxImages - (_selectedImages.length + _remainingUrls.length);
    if (remainingCount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Maximum ${widget.maxImages} images allowed')),
        );
      }
      return;
    }

    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          for (
            var i = 0;
            i < pickedFiles.length &&
                _selectedImages.length + _remainingUrls.length <
                    widget.maxImages;
            i++
          ) {
            _selectedImages.add(File(pickedFiles[i].path));
          }
        });
        widget.onImagesSelected(_selectedImages);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick images: $e')));
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    widget.onImagesSelected(_selectedImages);
  }

  void _removeExistingImage(int index) {
    setState(() {
      _remainingUrls.removeAt(index);
    });
    widget.onExistingImagesChanged?.call(_remainingUrls);
  }

  void _clearAllImages() {
    setState(() {
      _selectedImages.clear();
      _remainingUrls.clear();
    });
    widget.onImagesSelected(_selectedImages);
    widget.onExistingImagesChanged?.call(_remainingUrls);
  }
}

class _AddPhotoButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPhotoButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.blue.withValues(alpha: 0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, color: Colors.blue[700], size: 32),
            const SizedBox(height: 4),
            Text(
              'Add Photo',
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final File image;
  final VoidCallback onRemove;

  const _ImageTile({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              image,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkImageTile extends StatelessWidget {
  final String url;
  final VoidCallback onRemove;

  const _NetworkImageTile({required this.url, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _QuickPhotoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickPhotoChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
