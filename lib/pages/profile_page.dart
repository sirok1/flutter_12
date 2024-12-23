import 'package:flutter/material.dart';
import 'package:flutter_4/components/profile_text_field.dart';
import 'package:flutter_4/page_wrapper.dart';
import 'package:flutter_4/pages/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (ctx) => EditProfilePage(user: user))))
          ],
        ),
        body: Column(
          children: [
            Center(
              child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(widget.user.imageUrl)),
            ),
            const SizedBox(height: 10),
            Text(user.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                                  value: user.getFieldByIndex(index),
                                  icon: [Icons.email, Icons.phone][index]),
                              const SizedBox(height: 16),
                            ]);
                      },
                    )))
          ],
        ));
  }
}
