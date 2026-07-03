import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactSelectionScreen extends StatefulWidget {
  final Function(String name, String phone, String email) onContactSelected;

  const ContactSelectionScreen({
    super.key,
    required this.onContactSelected,
  });

  @override
  State<ContactSelectionScreen> createState() => _ContactSelectionScreenState();
}

class _ContactSelectionScreenState extends State<ContactSelectionScreen> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = true;
  bool _hasPermission = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissionAndLoadContacts() async {
    print('🔍 Starting permission request...');
    
    // Check current permission status first
    final currentStatus = await Permission.contacts.status;
    print('🔍 Current permission status: $currentStatus');
    
    if (currentStatus.isGranted) {
      print('✅ Permission already granted');
      setState(() {
        _hasPermission = true;
      });
      await _loadContacts();
      return;
    }
    
    print('📞 Requesting contacts permission...');
    // Request permission
    final permission = await Permission.contacts.request();
    print('📞 Permission request result: $permission');
    
    if (permission.isGranted) {
      print('✅ Permission granted!');
      setState(() {
        _hasPermission = true;
      });
      await _loadContacts();
    } else {
      print('❌ Permission denied: $permission');
      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadContacts() async {
    try {
      print('📱 Loading contacts...');
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );
      
      print('📱 Loaded ${contacts.length} contacts');
      
      setState(() {
        _contacts = contacts;
        _filteredContacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading contacts: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading contacts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = _contacts;
      } else {
        _filteredContacts = _contacts.where((contact) {
          final name = contact.displayName.toLowerCase();
          final phone = contact.phones.isNotEmpty 
              ? contact.phones.first.number.toLowerCase()
              : '';
          final email = contact.emails.isNotEmpty 
              ? contact.emails.first.address.toLowerCase()
              : '';
          
          return name.contains(query.toLowerCase()) ||
                 phone.contains(query.toLowerCase()) ||
                 email.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _selectContact(Contact contact) {
    final name = contact.displayName;
    final phones = contact.phones.map((p) => p.number).toList();
    final email = contact.emails.isNotEmpty ? contact.emails.first.address : '';
    
    // If contact has multiple phones, show selection dialog
    if (phones.length > 1) {
      _showPhoneSelectionDialog(name, phones, email);
    } else {
      // Single phone or no phone - proceed directly
      final phone = phones.isNotEmpty ? phones.first : '';
      widget.onContactSelected(name, phone, email);
      Navigator.of(context).pop();
    }
  }

  void _showPhoneSelectionDialog(String name, List<String> phones, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Phone Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select a phone number for ${name}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...phones.map((phone) => ListTile(
              title: Text(phone),
              leading: const Icon(Icons.phone),
              onTap: () {
                Navigator.of(context).pop();
                widget.onContactSelected(name, phone, email);
                Navigator.of(context).pop();
              },
            )).toList(),
            const Divider(),
            ListTile(
              title: Text('Import All Phone Numbers'),
              leading: const Icon(Icons.phone_android),
              onTap: () {
                Navigator.of(context).pop();
                // Import all phones as a comma-separated string
                final allPhones = phones.join(', ');
                widget.onContactSelected(name, allPhones, email);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import Contact'),
        actions: [
          if (_hasPermission)
            IconButton(
              onPressed: _loadContacts,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          if (_hasPermission)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _filterContacts('');
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                ),
                onChanged: _filterContacts,
              ),
            ),
          
          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (!_hasPermission) {
      return _buildPermissionDenied();
    }
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_filteredContacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.contacts_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No Results'
                  : 'No contacts found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            if (_searchController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  _filterContacts('');
                },
                child: Text('Clear Search'),
              ),
            ],
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: _filteredContacts.length,
      itemBuilder: (context, index) {
        final contact = _filteredContacts[index];
        return _buildContactTile(contact);
      },
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.contacts_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Contacts Permission Required',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This app needs access to your contacts to import customer information. Please grant permission in settings.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await openAppSettings();
              },
              icon: const Icon(Icons.settings),
              label: Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(Contact contact) {
    final name = contact.displayName;
    final phones = contact.phones.map((p) => p.number).toList();
    final email = contact.emails.isNotEmpty ? contact.emails.first.address : '';
    final hasMultiplePhones = phones.length > 1;
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        name.isNotEmpty ? name : 'Unknown Contact',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (phones.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    hasMultiplePhones 
                        ? '${phones.first} (+${phones.length - 1} more)'
                        : phones.first,
                  ),
                ),
              ],
            ),
          if (email.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.email, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(email),
              ],
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasMultiplePhones)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${phones.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
      onTap: () => _selectContact(contact),
    );
  }
}
