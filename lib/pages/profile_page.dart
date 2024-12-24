import 'package:flutter/material.dart';
import 'package:flutter_4/components/profile_text_field.dart';
import 'package:flutter_4/pages/edit_profile_page.dart';
import 'package:flutter_4/services/auth_service.dart';
import 'package:flutter_4/models/user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final authService = AuthService();
  late User _user = User('Loading...', '', '',
      'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fthumbs.dreamstime.com%2Fb%2Fdefault-profile-picture-avatar-photo-placeholder-vector-illustration-default-profile-picture-avatar-photo-placeholder-vector-189495158.jpg&f=1&nofb=1&ipt=5a3b8df2fbe61251fb5d0c178caf961f7fe07fce4bada9d2fc824089aa650a47&ipo=images');

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  void fetchUser() async {
    final user = await authService.getCurrentUser();
    if (user != null) {
      setState(() {
        _user = user;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Что-то пошло не так')));
      }
    }
  }

  void signOut() async {
    await authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Профиль",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _user.name != 'Loading...' ? () => Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => EditProfilePage(user: _user)),
            ) : null,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: signOut,
          ),
        ],
      ),
      body: _user.name == 'Loading...'
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_user.imageUrl),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _user.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                    child: ListView.builder(
                      itemCount: 2,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProfileTextField(
                              title: ["Почта", "Телефон"][index],
                              value: _user.getFieldByIndex(index),
                              icon: [Icons.email, Icons.phone][index],
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
