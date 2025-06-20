import 'package:trucky/screens/auth/currency_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../config/colors.dart';
import '../models/subscription.dart';
import '../services/pdf_service.dart';
import 'auth/login.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../services/currency_service.dart';
import '../utils/amount_formatter.dart'; // Added for custom amount formatting

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
  final PdfService _pdfService = PdfService();
  String currencyCode = CurrencyService.defaultCurrency;

  get subscription => null;
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final code = await CurrencyService.getCurrency();
    setState(() {
      currencyCode = code;
    });
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

    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Stack(
                children: [
                  // Profile picture
                  CircleAvatar(
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
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _showImageSourceOptions,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                _fullName ?? user?.email?.split('@')[0] ?? 'Utilisateur',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                user?.email ?? 'Pas d\'email',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 40),
              ListTile(
                leading: Icon(Icons.person, color: BTN700),
                title: Text('Paramètres du compte'),
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
                leading: Icon(Icons.currency_exchange, color: BTN700),
                title: Text('Devise'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(currencyCode),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
                onTap: () {
                  _showCurrencySelection(context);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.summarize, color: BTN700),
                title: Text('Rapports mensuels'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showMonthlyReportOptions(context);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.help, color: BTN700),
                title: Text('Aide et support'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showHelpAndSupport(context);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.info, color: BTN700),
                title: Text('À propos'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showAbout(context);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.red),
                title: Text('Déconnexion', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text('Déconnexion'),
                          content: Text(
                            'Êtes-vous sûr de vouloir vous déconnecter ?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Annuler'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('Déconnexion'),
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
        ),
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
                title: Text('Prendre une photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _selectImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choisir dans la galerie'),
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

  // Fixed image selection and upload to Firebase
  Future<void> _selectImage(ImageSource source) async {
    try {
      // Show loading indicator while processing
      setState(() => _isLoading = true);

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile == null) {
        setState(() => _isLoading = false);
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Utilisateur non connecté')));
        return;
      }

      final File imageFile = File(pickedFile.path);
      if (!await imageFile.exists()) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fichier image non trouvé')));
        return;
      }

      // Simple file name with timestamp to avoid any issues
      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

      try {
        // Create storage reference with explicit bucket path
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('user_profiles')
            .child(fileName);

        print('Uploading to: ${storageRef.fullPath}');

        // Start upload with basic metadata
        final UploadTask uploadTask = storageRef.putFile(
          imageFile,
          SettableMetadata(contentType: 'image/jpeg'),
        );

        // Show upload progress (optional)
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress =
              (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          print('Upload progress: $progress%');
        }, onError: (error) => print('Upload error: $error'));

        // Wait for completion and get download URL
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();

        print('Upload successful! Download URL: $downloadUrl');

        // Update Firestore with the new profile image URL
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              'profileImageUrl': downloadUrl,
              'updatedAt': FieldValue.serverTimestamp(),
            });

        // Update UI
        setState(() {
          _profileImageUrl = downloadUrl;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo de profil mise à jour avec succès')),
        );
      } on FirebaseException catch (e) {
        print('Firebase error: ${e.code} - ${e.message}');

        String errorMessage;
        switch (e.code) {
          case 'storage/unauthorized':
            errorMessage = 'Accès non autorisé au stockage Firebase.';
            break;
          case 'storage/canceled':
            errorMessage = 'Upload annulé.';
            break;
          case 'storage/unknown':
            errorMessage = 'Erreur inconnue, veuillez réessayer.';
            break;
          default:
            errorMessage = 'Erreur: ${e.message ?? e.code}';
        }

        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      } catch (e) {
        print('General upload error: $e');
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur lors de l\'upload: $e')));
      }
    } catch (e) {
      print('Error in image picker: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection d\'image')),
      );
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
                    'Paramètres du compte',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nom complet',
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
                      child: Text('Enregistrer les modifications'),
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
                              content: Text('Profil mis à jour avec succès'),
                            ),
                          );
                        } catch (e) {
                          print('Error updating profile: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Erreur lors de la mise à jour du profil. Veuillez réessayer.',
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
                    title: Text('Changer le mot de passe'),
                    onTap: () {
                      Navigator.pop(context);
                      _showChangePasswordDialog(context);
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text(
                      'Supprimer le compte',
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
                      'Paramètres de notification',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    SwitchListTile(
                      title: Text('Rappels d\'abonnement'),
                      subtitle: Text(
                        'Être notifié avant le renouvellement de l\'abonnement',
                      ),
                      value: reminderEnabled,
                      activeColor: BTN700,
                      onChanged: (value) {
                        setState(() => reminderEnabled = value);
                      },
                    ),
                    Divider(),
                    SwitchListTile(
                      title: Text('Alertes d\'expiration'),
                      subtitle: Text(
                        'Être notifié lorsque les abonnements expirent',
                      ),
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
                        child: Text('Enregistrer les paramètres'),
                        onPressed: () {
                          // Save notification settings logic would go here
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Paramètres de notification mis à jour',
                              ),
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
                  'Aide et support',
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
                  title: Text('Nous contacter'),
                  onTap: () {
                    Navigator.pop(context);
                    _showContactInfo(context);
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.feedback, color: BTN700),
                  title: Text('Envoyer des commentaires'),
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
            title: Text('À propos de Tracky'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Icon(Icons.subscriptions, size: 60, color: BTN700),
                ),
                SizedBox(height: 20),
                Text(
                  'Tracky',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Version 1.0.0'),
                SizedBox(height: 10),
                Text(
                  'Une application de gestion d\'abonnement pour vous aider à suivre et gérer toutes vos dépenses récurrentes en un seul endroit.',
                ),
                SizedBox(height: 20),
                Text('© 2025 Tracky Team. Tous droits réservés.'),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Fermer'),
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
            title: Text('Changer le mot de passe'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPassword,
                  decoration: InputDecoration(labelText: 'Mot de passe actuel'),
                  obscureText: true,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: newPassword,
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: confirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le nouveau mot de passe',
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Annuler'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: BTN700),
                child: Text('Changer'),
                onPressed: () {
                  // Logic to change password would go here
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mot de passe changé avec succès')),
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
            title: Text('Supprimer le compte'),
            content: Text(
              'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.',
            ),
            actions: [
              TextButton(
                child: Text('Annuler'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Supprimer'),
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
            title: Text('Questions fréquemment posées'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comment ajouter un abonnement ?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Appuyez sur le bouton + en bas de l\'écran d\'accueil pour ajouter un nouvel abonnement.',
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Comment modifier un abonnement ?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Appuyez sur l\'icône de modification sur n\'importe quelle carte d\'abonnement pour modifier ses détails.',
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Comment sont configurés les rappels de renouvellement ?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Par défaut, vous recevrez une notification 3 jours avant le renouvellement d\'un abonnement.',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('Fermer'),
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
            title: Text('Nous contacter'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('support@trackyapp.com'),

                SizedBox(height: 10),
                Text(
                  'Support WhatsApp:',
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
                Text('Heures:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Lundi à vendredi, 9h - 17h EST'),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Fermer'),
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
            title: Text('Envoyer des commentaires'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nous apprécions vos commentaires pour améliorer notre application !',
                ),
                SizedBox(height: 10),
                TextField(
                  controller: feedbackController,
                  decoration: InputDecoration(
                    labelText: 'Vos commentaires',
                    hintText: 'Dites-nous ce que vous pensez...',
                  ),
                  maxLines: 5,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Annuler'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: BTN700),
                child: Text('Soumettre'),
                onPressed: () {
                  // Submit feedback logic would go here
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Commentaires soumis. Merci !')),
                  );
                },
              ),
            ],
          ),
    );
  }

  void _showCurrencySelection(BuildContext context) async {
    final selectedCurrency = await showModalBottomSheet<String>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CurrencySelectionScreen(),
    );

    if (selectedCurrency != null) {
      await CurrencyService.setCurrency(selectedCurrency);
      setState(() {
        currencyCode = selectedCurrency;
      });
    }
  }

  void _showMonthlyReportOptions(BuildContext context) {
    // Default to current month
    DateTime selectedMonth = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
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
                      'Résumé mensuel des abonnements',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Sélectionnez un mois et une année pour voir tous les abonnements payés pendant cette période.',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedMonth,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          initialDatePickerMode: DatePickerMode.year,
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light(primary: BTN700),
                                buttonTheme: ButtonThemeData(
                                  textTheme: ButtonTextTheme.primary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (picked != null) {
                          setState(() {
                            selectedMonth = DateTime(
                              picked.year,
                              picked.month,
                              1,
                            );
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MMMM yyyy').format(selectedMonth),
                              style: TextStyle(fontSize: 16),
                            ),
                            Icon(Icons.calendar_month, color: BTN700),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BTN700,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showMonthlySubscriptionSummary(
                            context,
                            selectedMonth,
                          );
                        },
                        child: Text('Voir le résumé'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Future<void> _showMonthlySubscriptionSummary(
    BuildContext context,
    DateTime selectedMonth,
  ) async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Vous devez être connecté pour voir les données d\'abonnement',
            ),
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Calculate the start and end of the selected month
      final DateTime startOfMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month,
        1,
      );
      final DateTime endOfMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month + 1,
        0,
        23,
        59,
        59,
      );

      // First, query all subscriptions that exist for this user
      final allSubscriptionsSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('subscriptions')
              .get();

      // Transform the data
      final List<Map<String, dynamic>> subscriptions = [];

      for (var doc in allSubscriptionsSnapshot.docs) {
        final sub = Subscription.fromFirestore(doc);

        // Find all payment dates within the selected month
        DateTime paymentDate = sub.startDate;
        while (paymentDate.isBefore(endOfMonth)) {
          if (paymentDate.isAfter(startOfMonth) ||
              paymentDate.isAtSameMomentAs(startOfMonth)) {
            subscriptions.add({
              'name': sub.name,
              'amount': sub.price,
              'currency': sub.currency,
              'paymentDate': paymentDate,
            });
          }

          // Move to the next payment date based on duration
          switch (sub.paymentDuration.toLowerCase()) {
            case 'quotidien':
              paymentDate = paymentDate.add(const Duration(days: 1));
              break;
            case 'hebdomadaire':
              paymentDate = paymentDate.add(const Duration(days: 7));
              break;
            case 'annuel':
              paymentDate = DateTime(
                paymentDate.year + 1,
                paymentDate.month,
                paymentDate.day,
              );
              break;
            case 'mensuel':
            default:
              // A more robust way to add a month
              int year = paymentDate.year;
              int month = paymentDate.month + 1;
              if (month > 12) {
                month = 1;
                year++;
              }
              int day = paymentDate.day;
              // Handle cases where the next month has fewer days
              final daysInMonth = DateTime(year, month + 1, 0).day;
              if (day > daysInMonth) {
                day = daysInMonth;
              }
              paymentDate = DateTime(year, month, day);
              break;
          }
        }
      }

      // Sort by payment date
      subscriptions.sort(
        (a, b) => (a['paymentDate'] as DateTime).compareTo(
          b['paymentDate'] as DateTime,
        ),
      );

      setState(() => _isLoading = false);

      if (subscriptions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Aucun abonnement trouvé pour ${DateFormat('MMMM yyyy').format(selectedMonth)}',
            ),
          ),
        );
        return;
      }

      // Calculate total amount for the dialog in the selected currency
      double totalAmount = 0;
      for (final subscription in subscriptions) {
        totalAmount += CurrencyService.convertAmount(
          subscription['amount'],
          subscription['currency'],
          currencyCode,
        );
      }

      // Show the summary in a dialog
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Résumé mensuel'),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(selectedMonth),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(),
                    Container(
                      height: 300,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            DataTable(
                              columns: [
                                DataColumn(
                                  label: Text(
                                    'Nom',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Date',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Montant',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              rows:
                                  subscriptions.map((subscription) {
                                    final convertedAmount =
                                        CurrencyService.convertAmount(
                                          subscription['amount'],
                                          subscription['currency'],
                                          currencyCode,
                                        );
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(subscription['name'])),
                                        DataCell(
                                          Text(
                                            DateFormat('dd/MM').format(
                                              subscription['paymentDate'],
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            formatAmountWithCurrencyAfter(
                                              convertedAmount,
                                              currencyCode,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Total : ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            formatAmountWithCurrencyAfter(
                              totalAmount,
                              currencyCode,
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Fermer'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: BTN700),
                  child: Text('Exporter en PDF'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _exportPdfReport(subscriptions, selectedMonth);
                  },
                ),
              ],
            ),
      );
    } catch (e) {
      print('Error fetching subscription data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors du chargement des données d\'abonnement. Veuillez réessayer.',
          ),
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportPdfReport(
    List<Map<String, dynamic>> subscriptions,
    DateTime selectedMonth,
  ) async {
    if (!mounted) return;

    // Show loading state
    setState(() => _isLoading = true);

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10),
              Text('Création du rapport...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      try {
        // Generate the PDF with better error handling
        final filePath = await _pdfService.generateMonthlySubscriptionReport(
          userName: _fullName ?? 'User',
          subscriptions: subscriptions,
          selectedMonth: selectedMonth,
          currencyCode: currencyCode,
        );

        print("PDF successfully created at: $filePath");

        // Open the file
        final openResult = await OpenFile.open(filePath);
        if (openResult.type != ResultType.done) {
          throw 'Could not open the file: ${openResult.message}';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Rapport créé et ouvert avec succès'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        print('PDF Generation or Opening Error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Rapport créé mais impossible de l\'ouvrir automatiquement. Veuillez vérifier votre dossier de téléchargements.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
