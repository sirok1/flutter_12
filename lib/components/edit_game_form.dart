import 'package:flutter/material.dart';
import 'package:flutter_4/models/game.dart';
import 'package:flutter_4/services/api_service.dart';

class EditGameForm extends StatefulWidget {
  final Game game;
  final Function(Game) onGameUpdated;

  const EditGameForm({super.key, required this.game, required this.onGameUpdated});

  @override
  _EditGameFormState createState() => _EditGameFormState();
}

class _EditGameFormState extends State<EditGameForm> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String description;
  late String imageUrl;
  late int price;

  @override
  void initState() {
    super.initState();
    name = widget.game.name;
    description = widget.game.description;
    imageUrl = widget.game.imageUrl;
    price = widget.game.price;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Редактировать игру'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'Название'),
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                initialValue: description,
                decoration: InputDecoration(labelText: 'Описание'),
                maxLines: null,
                onSaved: (value) => description = value!,
              ),
              TextFormField(
                initialValue: imageUrl,
                decoration: InputDecoration(labelText: 'URL изображения'),
                onSaved: (value) => imageUrl = value!,
              ),
              TextFormField(
                initialValue: price.toString(),
                decoration: InputDecoration(labelText: 'Цена'),
                keyboardType: TextInputType.number,
                onSaved: (value) => price = int.parse(value!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Game updatedGame = widget.game.copyWith(
                      name: name,
                      description: description,
                      imageUrl: imageUrl,
                      price: price,
                    );
                    await ApiService().updateGame(updatedGame);
                    widget.onGameUpdated(updatedGame);
                    Navigator.pop(context);
                  }
                },
                child: Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
