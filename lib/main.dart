import 'package:flutter/material.dart';
import 'package:web_socket_demo/screens/web_socket_page.dart';

void main() => runApp(WebSocketDemo());

class WebSocketDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'WebSocket Demo';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: WebSocketPage(title: title),
      ),
    );
  }
}
