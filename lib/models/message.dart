import 'package:flutter/material.dart';

class Message {
  final String text;
  final Color color;

  Message({@required this.text, @required this.color});

  static ListView getMessages(List<Message> messages) {
    List<ListTile> _messageListTiles = [];

    for (Message message in messages) {
      _messageListTiles.add(
        ListTile(
          title: Container(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                message.text,
                style: TextStyle(fontSize: 16),
              ),
            ),
            color: message.color,
          ),
        ),
      );
    }

    return ListView(
      children: _messageListTiles,
    );
  }
}
