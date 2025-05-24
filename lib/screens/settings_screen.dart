import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/colors.dart';
import 'auth/login.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 60,
            backgroundColor: BTN500,
            child: Text(
              user?.email?.isNotEmpty == true
                  ? user!.email![0].toUpperCase()
                  : '?',
              style: TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            user?.email ?? 'No email',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          ListTile(
            leading: Icon(Icons.person, color: BTN700),
            title: Text('Account Settings'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to account settings
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications, color: BTN700),
            title: Text('Notifications'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to notifications settings
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.help, color: BTN700),
            title: Text('Help & Support'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to help
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info, color: BTN700),
            title: Text('About'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to about
            },
          ),
          Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: Icon(Icons.exit_to_app),
            label: Text('Log Out'),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false,
              );
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
