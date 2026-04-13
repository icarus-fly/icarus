import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  PlatformFile? _selectedPdf;
  bool _isUploading = false;

  Future<void> _pickImages() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) return;

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick images: $e')),
      );
    }
  }

  Future<void> _pickPdf() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedPdf = result.files.first;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick PDF: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removePdf() {
    setState(() {
      _selectedPdf = null;
    });
  }

  bool get _hasContent => _selectedImages.isNotEmpty || _selectedPdf != null;

  void _continueToReportType() {
    if (!_hasContent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image or PDF')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/report-type',
      arguments: {
        'images': _selectedImages,
        'pdf': _selectedPdf,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Medical Report'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Upload Options
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Add Photos'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickPdf,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Add PDF'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Selected Content Preview
            if (_hasContent)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_selectedPdf != null)
                        _PdfPreviewCard(
                          file: _selectedPdf!,
                          onRemove: _removePdf,
                        ),

                      if (_selectedImages.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return _ImagePreviewCard(
                              image: _selectedImages[index],
                              onRemove: () => _removeImage(index),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload_file,
                        size: 64,
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Upload medical reports, scans, or prescriptions',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Supported: Photos, PDF documents, scanned reports',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                        textScaler: TextScaler.linear(0.9),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Continue Button
            ElevatedButton(
              onPressed: _hasContent ? _continueToReportType : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _hasContent
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
              ),
              child: Text(
                'Continue to Analysis',
                style: TextStyle(
                  color: _hasContent
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePreviewCard extends StatelessWidget {
  final XFile image;
  final VoidCallback onRemove;

  const _ImagePreviewCard({
    required this.image,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
          child: FutureBuilder<String?>(
            future: image.readAsBytes().then((bytes) => null),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return Image.memory(
                snapshot.data as Uint8List? ?? Uint8List(0),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 32,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  );
                },
              );
            },
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: CircleAvatar(
            radius: 14,
            backgroundColor: Theme.of(context).colorScheme.error,
            child: IconButton(
              icon: const Icon(Icons.close, size: 14),
              color: Theme.of(context).colorScheme.onError,
              onPressed: onRemove,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}

class _PdfPreviewCard extends StatelessWidget {
  final PlatformFile file;
  final VoidCallback onRemove;

  const _PdfPreviewCard({
    required this.file,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: 32,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${(file.size / 1024).toStringAsFixed(1)} KB',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}