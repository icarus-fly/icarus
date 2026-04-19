import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../app/theme.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/language_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) return;

    try {
      final doc = await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (doc.exists) {
        setState(() {
          _userData = doc.data();
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      // Navigator should handle redirection via router
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get(lang, 'profileTitle')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundImage: _currentUser!.photoURL != null
                                ? NetworkImage(_currentUser!.photoURL!)
                                : null,
                            child: _currentUser!.photoURL == null
                                ? const Icon(Icons.person, size: 32)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentUser!.displayName ?? 'Unknown User',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currentUser!.email ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Member since ${_userData?['createdAt']?.toDate()?.year ?? '2024'}',
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

                  // Subscription Section
                  Text(
                    AppStrings.get(lang, 'subscription'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Free Feature
                          ListTile(
                            leading: const Icon(Icons.check_circle, color: Colors.green),
                            title: Text(AppStrings.get(lang, 'freeFeature')),
                            subtitle: const Text('Unlimited report analysis'),
                          ),

                          // Family Slots
                          ListTile(
                            leading: const Icon(Icons.family_restroom, color: Colors.blue),
                            title: Text(AppStrings.get(lang, 'paidFeatureFamily')),
                            subtitle: Text('Family members: ${_userData?['subscription']?['familySlots'] ?? 0}/5'),
                            trailing: ElevatedButton(
                              onPressed: () {
                                // TODO: Implement family slot purchase
                              },
                              child: Text(AppStrings.get(lang, 'payNow')),
                            ),
                          ),

                          // Health Tracking
                          ListTile(
                            leading: const Icon(Icons.track_changes, color: Colors.purple),
                            title: Text(AppStrings.get(lang, 'paidFeatureTracking')),
                            subtitle: const Text('Advanced health monitoring'),
                            trailing: ElevatedButton(
                              onPressed: () {
                                // TODO: Implement tracking purchase
                              },
                              child: Text(AppStrings.get(lang, 'payNow')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // App Settings
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),

                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: const Text('Language'),
                          subtitle: Text('Current: ${lang.toUpperCase()}'),
                          onTap: () {
                            Navigator.pushNamed(context, '/language');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.notifications),
                          title: const Text('Notifications'),
                          trailing: Switch(
                            value: true,
                            onChanged: (value) {
                              // TODO: Implement notification settings
                            },
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.volume_up),
                          title: const Text('Audio Explanations'),
                          trailing: Switch(
                            value: true,
                            onChanged: (value) {
                              // TODO: Implement audio settings
                            },
                          ),
                        ),
                      ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // App Info
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Traqa Health App',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Version 1.0.0',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.get(lang, 'disclaimer'),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}