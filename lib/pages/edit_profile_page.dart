import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_4/models/user.dart';
import 'package:flutter_4/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class EditProfilePage extends StatefulWidget {
  final User user;
  const EditProfilePage({super.key, required this.user});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String _imagePath = '';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final authService = AuthService();

  void _changeProfileImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final location = await getApplicationDocumentsDirectory();
    final name = basename(image.name);
    final imageFile = File('${location.path}/${name}');
    final newImage = await File(image.path).copy(imageFile.path);
    setState(() {
      () => _imagePath = newImage.path;
    });
  }

  void _saveChanges(BuildContext context) {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Вы заполнили не все поля")));
    } else {
      authService.updateUserProfile(
          _nameController.text, _emailController.text, _phoneController.text);
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _emailController.text = widget.user.email;
    _phoneController.text = widget.user.phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Изменение профиля",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () => _saveChanges(context),
              icon: const Icon(Icons.save))
        ],
      ),
      body: Column(
        children: [
          Center(
            child: InkWell(
              onTap: _changeProfileImage,
              child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(_imagePath.length > 1
                      ? _imagePath
                      : widget.user.imageUrl)),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              children: [
                TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Укажите имя';
                      }
                    },
                    decoration: InputDecoration(
                        labelText: 'Имя',
                        hintText: 'Введите ваше имя',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0))),
                    textInputAction: TextInputAction.done,
                    controller: _nameController),
                const SizedBox(height: 15),
                TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Укажите почту';
                      }
                    },
                    decoration: InputDecoration(
                        labelText: 'Почта',
                        hintText: 'Введите вашу почту',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0))),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    controller: _emailController),
                const SizedBox(height: 15),
                TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Укажите телефон';
                      }
                    },
                    decoration: InputDecoration(
                        labelText: 'Телефон',
                        hintText: 'Введите ваш телефон',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0))),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.phone,
                    controller: _phoneController)
              ],
            ),
          )
        ],
      ),
    );
  }
}
