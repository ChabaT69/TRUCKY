import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../config/colors.dart';
import 'auth/login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _fullName;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Improved user profile loading
  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);

        final userData = await userDoc.get();

        if (!userData.exists) {
          // Initialize user document with email and generate a default name
          String defaultName =
              user.displayName ?? user.email?.split('@')[0] ?? 'User';

          await userDoc.set({
            'email': user.email,
            'fullName': defaultName,
            'createdAt': FieldValue.serverTimestamp(),
          });

          setState(() {
            _fullName = defaultName;
            _profileImageUrl = null;
          });
        } else {
          // User document exists, load data
          final data = userData.data()!;

          setState(() {
            _fullName = data['fullName'];
            _profileImageUrl = data['profileImageUrl'];
          });
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Stack(
            children: [
              // Profile picture
              _isLoading
                  ? CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    child: CircularProgressIndicator(),
                  )
                  : CircleAvatar(
                    radius: 60,
                    backgroundColor: BTN500,
                    backgroundImage:
                        _profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : null,
                    child:
                        _profileImageUrl == null
                            ? Text(
                              _fullName?.isNotEmpty == true
                                  ? _fullName![0].toUpperCase()
                                  : user?.email?[0].toUpperCase() ?? '?',
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                              ),
                            )
                            : null,
                  ),
              // Edit button overlay
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: BTN700,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    onPressed: _showImageSourceOptions,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _fullName ?? user?.email?.split('@')[0] ?? 'User',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            user?.email ?? 'No email',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 40),
          ListTile(
            leading: Icon(Icons.person, color: BTN700),
            title: Text('Account Settings'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showAccountSettings(context, user);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications, color: BTN700),
            title: Text('Notifications'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showNotificationSettings(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.help, color: BTN700),
            title: Text('Help & Support'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showHelpAndSupport(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info, color: BTN700),
            title: Text('About'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showAbout(context);
            },
          ),
          Spacer(),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.red),
            title: Text('Log Out', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('Log Out'),
                      content: Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text('Log Out'),
                        ),
                      ],
                    ),
              );

              if (confirm == true) {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                  (route) => false,
                );
              }
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Take a photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _selectImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _selectImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Image selection and upload to Firebase
  Future<void> _selectImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      setState(() => _isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final File imageFile = File(pickedFile.path);
      final fileName =
          '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_profiles')
          .child(fileName);

      try {
        final uploadTask = storageRef.putFile(imageFile);
        final snapshot = await uploadTask.whenComplete(() => null);
        final downloadUrl = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'profileImageUrl': downloadUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        setState(() {
          _profileImageUrl = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile picture updated successfully')),
        );
      } catch (storageError) {
        print('Error uploading image: $storageError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image. Please try again.')),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAccountSettings(BuildContext context, User? user) {
    // Use the current name from Firestore rather than possibly null value
    final TextEditingController nameController = TextEditingController(
      text: _fullName ?? '',
    );

    final TextEditingController emailController = TextEditingController(
      text: user?.email,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Account Settings',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person, color: BTN700),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: BTN700),
                      border: OutlineInputBorder(),
                    ),
                    enabled: false,
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BTN700,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: Text('Save Changes'),
                      onPressed: () async {
                        // Save the updated name to Firestore
                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .set({
                                  'fullName': nameController.text,
                                  'updatedAt': FieldValue.serverTimestamp(),
                                }, SetOptions(merge: true));

                            setState(() {
                              _fullName = nameController.text;
                            });
                          }

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Profile updated successfully'),
                            ),
                          );
                        } catch (e) {
                          print('Error updating profile: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error updating profile. Please try again.',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.lock, color: BTN700),
                    title: Text('Change Password'),
                    onTap: () {
                      Navigator.pop(context);
                      _showChangePasswordDialog(context);
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteAccountConfirmation(context);
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              bool reminderEnabled = true;
              bool expiryEnabled = true;

              return Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Notification Settings',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    SwitchListTile(
                      title: Text('Subscription Reminders'),
                      subtitle: Text(
                        'Get notified before subscription renewal',
                      ),
                      value: reminderEnabled,
                      activeColor: BTN700,
                      onChanged: (value) {
                        setState(() => reminderEnabled = value);
                      },
                    ),
                    Divider(),
                    SwitchListTile(
                      title: Text('Expiry Alerts'),
                      subtitle: Text('Get notified when subscriptions expire'),
                      value: expiryEnabled,
                      activeColor: BTN700,
                      onChanged: (value) {
                        setState(() => expiryEnabled = value);
                      },
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BTN700,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text('Save Settings'),
                        onPressed: () {
                          // Save notification settings logic would go here
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Notification settings updated'),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
    );
  }

  void _showHelpAndSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Help & Support',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.help_outline, color: BTN700),
                  title: Text('FAQs'),
                  onTap: () {
                    Navigator.pop(context);
                    _showFAQs(context);
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.contacts, color: BTN700),
                  title: Text('Contact Us'),
                  onTap: () {
                    Navigator.pop(context);
                    _showContactInfo(context);
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.feedback, color: BTN700),
                  title: Text('Send Feedback'),
                  onTap: () {
                    Navigator.pop(context);
                    _showFeedbackForm(context);
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('About Trucky'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Icon(Icons.subscriptions, size: 60, color: BTN700),
                ),
                SizedBox(height: 20),
                Text(
                  'Trucky',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Version 1.0.0'),
                SizedBox(height: 10),
                Text(
                  'A subscription management app to help you track and manage all your recurring expenses in one place.',
                ),
                SizedBox(height: 20),
                Text('© 2025 Trucky Team. All rights reserved.'),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Close'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  // Helper dialogs and forms
  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController currentPassword = TextEditingController();
    final TextEditingController newPassword = TextEditingController();
    final TextEditingController confirmPassword = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Change Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPassword,
                  decoration: InputDecoration(labelText: 'Current Password'),
                  obscureText: true,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: newPassword,
                  decoration: InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: confirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: BTN700),
                child: Text('Change'),
                onPressed: () {
                  // Logic to change password would go here
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password changed successfully')),
                  );
                },
              ),
            ],
          ),
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Account'),
            content: Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Delete'),
                onPressed: () {
                  // Delete account logic would go here
                  Navigator.of(context).pop();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
    );
  }

  void _showFAQs(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Frequently Asked Questions'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How do I add a subscription?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Tap the + button at the bottom of the home screen to add a new subscription.',
                  ),
                  SizedBox(height: 10),
                  Text(
                    'How do I edit a subscription?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Tap the edit icon on any subscription card to modify its details.',
                  ),
                  SizedBox(height: 10),
                  Text(
                    'How are renewal reminders set?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'By default, you will receive a notification 3 days before a subscription renews.',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('Close'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  void _showContactInfo(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Contact Us'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('support@truckyapp.com'),

                SizedBox(height: 10),
                Text(
                  'WhatsApp support:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () {
                    // Launch WhatsApp with this number when tapped
                    // You may need to add url_launcher package to implement this functionality
                    // launchUrl(Uri.parse('https://wa.me/15642127352'));
                  },
                  child: Text(
                    '+1 (564) 212-7352',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text('Hours:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Monday to Friday, 9AM - 5PM EST'),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Close'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  void _showFeedbackForm(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Send Feedback'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('We appreciate your feedback to improve our app!'),
                SizedBox(height: 10),
                TextField(
                  controller: feedbackController,
                  decoration: InputDecoration(
                    labelText: 'Your Feedback',
                    hintText: 'Tell us what you think...',
                  ),
                  maxLines: 5,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: BTN700),
                child: Text('Submit'),
                onPressed: () {
                  // Submit feedback logic would go here
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Feedback submitted. Thank you!')),
                  );
                },
              ),
            ],
          ),
    );
  }
}
