import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportTypeScreen extends ConsumerStatefulWidget {
  const ReportTypeScreen({super.key});

  @override
  ConsumerState<ReportTypeScreen> createState() => _ReportTypeScreenState();
}

class _ReportTypeScreenState extends ConsumerState<ReportTypeScreen> {
  String? _selectedType;

  final Map<String, Map<String, dynamic>> _reportTypes = {
    'lab_report': {
      'title': 'Lab Test Report',
      'icon': Icons.bloodtype,
      'description': 'Blood tests, urine tests, pathology reports',
      'color': Colors.red,
    },
    'prescription': {
      'title': 'Prescription',
      'icon': Icons.medication,
      'description': 'Doctor prescriptions, medication lists',
      'color': Colors.blue,
    },
    'mri_scan': {
      'title': 'MRI Scan',
      'icon': Icons.mri,
      'description': 'MRI reports, brain scans, joint imaging',
      'color': Colors.purple,
    },
    'xray': {
      'title': 'X-Ray Report',
      'icon': Icons.broken_image,
      'description': 'X-ray films, bone fracture reports',
      'color': Colors.green,
    },
    'other': {
      'title': 'Other Medical Document',
      'icon': Icons.description,
      'description': 'Discharge summaries, doctor notes, ECG reports',
      'color': Colors.orange,
    },
  };

  void _selectType(String type) {
    setState(() {
      _selectedType = type;
    });
  }

  void _continueToLanguage() {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a report type')),
      );
      return;
    }

    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};

    Navigator.pushNamed(
      context,
      '/output-language',
      arguments: {
        ...routeArgs,
        'reportType': _selectedType,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final hasImages = (routeArgs['images'] as List<XFile>?)?.isNotEmpty ?? false;
    final hasPdf = routeArgs['pdf'] != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Report Type'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Upload Summary
            if (hasImages || hasPdf)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(
                        hasPdf ? Icons.picture_as_pdf : Icons.photo_library,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasPdf
                                  ? '1 PDF document'
                                  : '${routeArgs['images']?.length ?? 0} photos',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              'Ready for analysis',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Report Type Selection
            Text(
              'What type of medical document is this?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Select the most appropriate category for accurate AI analysis',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            // Report Type Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: _reportTypes.length,
                itemBuilder: (context, index) {
                  final type = _reportTypes.keys.elementAt(index);
                  final data = _reportTypes[type]!;
                  final isSelected = _selectedType == type;

                  return _ReportTypeCard(
                    title: data['title'] as String,
                    icon: data['icon'] as IconData,
                    description: data['description'] as String,
                    color: data['color'] as Color,
                    isSelected: isSelected,
                    onTap: () => _selectType(type),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Continue Button
            ElevatedButton(
              onPressed: _selectedType != null ? _continueToLanguage : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _selectedType != null
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
              ),
              child: Text(
                'Choose Language',
                style: TextStyle(
                  color: _selectedType != null
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

class _ReportTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReportTypeCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected
          ? color.withOpacity(0.1)
          : Theme.of(context).colorScheme.surface,
      elevation: isSelected ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? color : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : null,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? color.withOpacity(0.8)
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      ),
    );
  }
}