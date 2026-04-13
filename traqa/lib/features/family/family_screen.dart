import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/family_provider.dart';

class FamilyScreen extends ConsumerStatefulWidget {
  const FamilyScreen({super.key});

  @override
  ConsumerState<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends ConsumerState<FamilyScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isAddingMember = false;

  Future<void> _addFamilyMember() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final availableSlots = await FamilyService().getAvailableFamilySlots();
    if (availableSlots <= 0) {
      _showPurchaseDialog();
      return;
    }

    setState(() {
      _isAddingMember = true;
    });

    // Show add member dialog
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddFamilyMemberDialog(),
    );

    if (result != null) {
      try {
        await FamilyService().addFamilyMember(result);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Family member added successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add family member: $e')),
        );
      }
    }

    setState(() {
      _isAddingMember = false;
    });
  }

  void _showPurchaseDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final lang = ref.read(languageProvider);
        return AlertDialog(
          title: const Text('Upgrade Required'),
          content: Text(
            'You need to purchase additional family slots to add more members.\n\n'
            'Each slot costs ₹50 per year.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement purchase flow
                _navigateToPayment('family_slot_yearly');
              },
              child: Text(AppStrings.get(lang, 'payNow')),
            ),
          ],
        );
      },
    );
  }

  void _navigateToPayment(String feature) {
    // TODO: Implement payment navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment integration coming soon')),
    );
  }

  Future<void> _editFamilyMember(Map<String, dynamic> member) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddFamilyMemberDialog(initialData: member),
    );

    if (result != null) {
      try {
        await FamilyService().updateFamilyMember(member['id'], result);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Family member updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update family member: $e')),
        );
      }
    }
  }

  Future<void> _deleteFamilyMember(Map<String, dynamic> member) async {
    final confirmed = await showDialog<b>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Family Member'),
        content: Text(
          'Are you sure you want to delete ${member['name']}?\n'
          'This will also remove all their health reports.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FamilyService().deleteFamilyMember(member['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${member['name']} removed from family')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete family member: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final familyMembersAsync = ref.watch(currentUserFamilyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get(lang, 'tabFamily')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: _isAddingMember
                ? const CircularProgressIndicator()
                : const Icon(Icons.add),
            onPressed: _isAddingMember ? null : _addFamilyMember,
          ),
        ],
      ),
      body: familyMembersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (members) {
          if (members.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return _FamilyMemberCard(
                member: member,
                onEdit: () => _editFamilyMember(member),
                onDelete: () => _deleteFamilyMember(member),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final lang = ref.read(languageProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.family_restroom,
            size: 64,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.get(lang, 'familyTitle'),
            style: GoogleFonts.ibmPlexSans(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: TraqaTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your family members to track their health together',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 16,
              color: TraqaTheme.textSecond,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addFamilyMember,
            icon: const Icon(Icons.add),
            label: Text(AppStrings.get(lang, 'addMember')),
          ),
        ],
      ),
    );
  }
}

class _FamilyMemberCard extends StatelessWidget {
  final Map<String, dynamic> member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FamilyMemberCard({
    required this.member,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getAvatarColor(member['relationship']),
          child: Text(
            member['name']?[0]?.toUpperCase() ?? '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          member['name'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatRelationship(member['relationship'])),
            if (member['age'] != null) Text('Age: ${member['age']}'),
            if (member['location'] != null) Text('Location: ${member['location']}'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete'),
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
        ),
        onTap: () {
          // TODO: Navigate to member's health dashboard
        },
      ),
    );
  }

  Color _getAvatarColor(String? relationship) {
    final colors = {
      'parent': Colors.blue,
      'child': Colors.green,
      'spouse': Colors.purple,
      'sibling': Colors.orange,
      'grandparent': Colors.red,
      'other': Colors.grey,
    };
    return colors[relationship] ?? Colors.grey;
  }

  String _formatRelationship(String? relationship) {
    final relationships = {
      'parent': 'Parent',
      'child': 'Child',
      'spouse': 'Spouse',
      'sibling': 'Sibling',
      'grandparent': 'Grandparent',
      'other': 'Other',
    };
    return relationships[relationship] ?? 'Family Member';
  }
}

class AddFamilyMemberDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const AddFamilyMemberDialog({super.key, this.initialData});

  @override
  State<AddFamilyMemberDialog> createState() => _AddFamilyMemberDialogState();
}

class _AddFamilyMemberDialogState extends State<AddFamilyMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();
  String _relationship = 'parent';
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _nameController.text = widget.initialData!['name'] ?? '';
      _ageController.text = widget.initialData!['age']?.toString() ?? '';
      _locationController.text = widget.initialData!['location'] ?? '';
      _relationship = widget.initialData!['relationship'] ?? 'parent';
      _phoneNumber = widget.initialData!['phoneNumber'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialData == null ? 'Add Family Member' : 'Edit Family Member'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age (optional)',
                  prefixIcon: Icon(Icons.cake),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _relationship,
                decoration: const InputDecoration(
                  labelText: 'Relationship',
                  prefixIcon: Icon(Icons.group),
                ),
                items: const [
                  DropdownMenuItem(value: 'parent', child: Text('Parent')),
                  DropdownMenuItem(value: 'child', child: Text('Child')),
                  DropdownMenuItem(value: 'spouse', child: Text('Spouse')),
                  DropdownMenuItem(value: 'sibling', child: Text('Sibling')),
                  DropdownMenuItem(value: 'grandparent', child: Text('Grandparent')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() {
                    _relationship = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location/City (optional)',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number (optional)',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) => _phoneNumber = value,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final memberData = {
        'name': _nameController.text,
        'age': _ageController.text.isNotEmpty ? int.tryParse(_ageController.text) : null,
        'relationship': _relationship,
        'location': _locationController.text,
        'phoneNumber': _phoneNumber,
      };

      Navigator.pop(context, memberData);
    }
  }
}