import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_4/models/message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _sendMessage() async {
    if (_auth.currentUser == null) {
      // Пользователь не авторизован
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Пожалуйста, войдите в систему, чтобы отправить сообщение.')),
      );
      return;
    }

    if (_controller.text.isNotEmpty) {
      final message = Message(
        senderId: _auth.currentUser!.uid,
        receiverId: 'ZkZbVKeSsQMAySgSss5QSon5Nop1',
        text: _controller.text,
        timestamp: DateTime.now(),
      );

      final chatId = 'ZkZbVKeSsQMAySgSss5QSon5Nop1';

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toMap());
      _controller.clear();
    }
  }

  String _getChatId(String userId, String receiverId) {
    return userId.hashCode <= receiverId.hashCode
        ? '$userId-$receiverId'
        : '$receiverId-$userId';
  }

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser == null) {
      return Scaffold(
          appBar: AppBar(
            title: Text('Чат с продавцом'),
          ),
          body: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Center(
              child: Text(
                'Пожалуйста, войдите в систему, чтобы использовать чат.',
                textAlign: TextAlign.center,
              ),
            ),
          ));
    }

    final chatId = 'ZkZbVKeSsQMAySgSss5QSon5Nop1';

    return Scaffold(
      appBar: AppBar(
        title: Text('Чат с продавцом'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs.map((doc) {
                  return Message.fromMap(doc.data() as Map<String, dynamic>);
                }).toList();

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _auth.currentUser!.uid;
                    return ListTile(
                      title: Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                                color: isMe ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                      subtitle: Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Text(
                          message.timestamp.toString(),
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Введите сообщение'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
