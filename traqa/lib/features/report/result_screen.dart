import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final String reportId;

  const ResultScreen({super.key, required this.reportId});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  bool _isLoading = true;
  Map<String, dynamic>? _reportData;

  @override
  void initState() {
    super.initState();
    _loadReportData();
    _setupTTS();
  }

  Future<void> _setupTTS() async {
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.5); // Slower for better understanding
  }

  Future<void> _loadReportData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reports')
          .doc(widget.reportId)
          .get();

      if (doc.exists) {
        setState(() {
          _reportData = doc.data();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load report: $e')),
      );
    }
  }

  Future<void> _toggleSpeak() async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() {
        _isSpeaking = false;
      });
    } else {
      final speakableText = _reportData?['speakableText'] as String? ?? '';
      if (speakableText.isNotEmpty) {
        await _tts.speak(speakableText);
        setState(() {
          _isSpeaking = true;
        });

        // Listen for when speech completes
        _tts.completionHandler = () {
          setState(() {
            _isSpeaking = false;
          });
        };
      }
    }
  }

  Future<void> _shareReport() async {
    try {
      final image = await _screenshotController.capture();
      if (image != null) {
        await Share.shareXFiles(
          [XFile.fromData(image, name: 'traqa_report.png', mimeType: 'image/png')],
          subject: 'Medical Report Summary from Traqa',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share: $e')),
      );
    }
  }

  Future<void> _contactDoctor() async {
    const doctorUrl = 'https://www.practo.com/search/doctors';
    if (await canLaunchUrl(Uri.parse(doctorUrl))) {
      await launchUrl(Uri.parse(doctorUrl));
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
      case 'good':
        return Colors.green;
      case 'warning':
      case 'slightly high':
      case 'slightly low':
        return Colors.orange;
      case 'critical':
      case 'high':
      case 'low':
      case 'abnormal':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
      case 'good':
        return Icons.check_circle;
      case 'warning':
      case 'slightly high':
      case 'slightly low':
        return Icons.warning;
      case 'critical':
      case 'high':
      case 'low':
      case 'abnormal':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_reportData == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Report not found'),
        ),
      );
    }

    final summary = _reportData!['summary'] as String? ?? '';
    final aiExplanation = _reportData!['aiExplanation'] as String? ?? '';
    final extractedValues = _reportData!['extractedValues'] as Map<String, dynamic>? ?? {};
    final medications = _reportData!['medications'] as List<dynamic>? ?? [];
    final memberName = _reportData!['memberName'] as String? ?? 'You';
    final reportType = _reportData!['reportType'] as String? ?? 'report';

    return Scaffold(
      appBar: AppBar(
        title: Text('$memberName\'s ${reportType.replaceAll('_', ' ').toUpperCase()}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSpeaking ? Icons.volume_off : Icons.volume_up),
            onPressed: _toggleSpeak,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareReport,
          ),
        ],
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Summary',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        summary,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Extracted Values
              if (extractedValues.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Key Findings',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ...extractedValues.entries.map((entry) {
                          final value = entry.value as Map<String, dynamic>;
                          final status = value['status'] as String? ?? '';
                          final color = _getStatusColor(status);

                          return ListTile(
                            leading: Icon(
                              _getStatusIcon(status),
                              color: color,
                            ),
                            title: Text(
                              entry.key,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            subtitle: Text(
                              '${value['value']} ${value['unit'] ?? ''}'.trim(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            trailing: Chip(
                              label: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: color.withOpacity(0.1),
                              side: BorderSide(color: color),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Medications
              if (medications.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medications',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ...medications.map((med) {
                          final medication = med as Map<String, dynamic>;
                          return ListTile(
                            leading: const Icon(Icons.medication, color: Colors.blue),
                            title: Text(
                              medication['name'] ?? 'Unknown',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (medication['dosage'] != null)
                                  Text('Dosage: ${medication['dosage']}'),
                                if (medication['frequency'] != null)
                                  Text('Frequency: ${medication['frequency']}'),
                                if (medication['purpose'] != null)
                                  Text('Purpose: ${medication['purpose']}'),
                              ].whereType<Widget>().toList(),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Detailed Explanation
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detailed Explanation',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      // Using HTML widget or simple text for now
                      Text(
                        aiExplanation.replaceAllMapped(
                          RegExp(r'<[^>]*>'),
                          (match) => '',
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              ElevatedButton.icon(
                onPressed: _contactDoctor,
                icon: const Icon(Icons.local_hospital),
                label: const Text('Find a Doctor Nearby'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}