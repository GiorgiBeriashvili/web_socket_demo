import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_demo/models/message.dart';
import 'package:web_socket_demo/states/web_socket_connection.dart';
import 'package:web_socket_demo/components/round_icon_button.dart';

class WebSocketPage extends StatefulWidget {
  final String title;

  WebSocketPage({Key key, this.title}) : super(key: key);

  @override
  _WebSocketPageState createState() => _WebSocketPageState();
}

class _WebSocketPageState extends State<WebSocketPage> {
  final _connectionController =
      TextEditingController(text: 'ws://echo.websocket.org');
  final _messageController = TextEditingController();

  final List<Message> _messages = [];

  IOWebSocketChannel _channel;
  WebSocketConnection _webSocketConnection = WebSocketConnection.disconnected;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _connectionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Connect to WebSocket',
              ),
              style: TextStyle(fontSize: 20),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8),
                child: RaisedButton(
                  color: Colors.green,
                  child: Text(
                    'CONNECT',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  onPressed:
                      _webSocketConnection == WebSocketConnection.connected
                          ? null
                          : () => _connect(_connectionController.text),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: RaisedButton(
                  color: Colors.red,
                  child: Text(
                    'DISCONNECT',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  onPressed:
                      _webSocketConnection == WebSocketConnection.disconnected
                          ? null
                          : _disconnect,
                ),
              ),
            ],
          ),
          Expanded(
            child: Message.getMessages(_messages),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: RaisedButton(
              color: Colors.lightBlue,
              child: Text(
                'CLEAR MESSAGES',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              onPressed: _messages.isNotEmpty
                  ? () => setState(() => _messages.clear())
                  : null,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Send Message',
                    ),
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: RoundIconButton(
                    color: _webSocketConnection == WebSocketConnection.connected
                        ? Colors.lightBlue
                        : Colors.grey,
                    icon: Icons.send,
                    onPressed:
                        _webSocketConnection == WebSocketConnection.connected
                            ? _sendMessage
                            : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _connect(url) {
    if (_webSocketConnection == WebSocketConnection.disconnected) {
      _channel = IOWebSocketChannel.connect(url);

      setState(() =>
          _messages.add(Message(text: 'CONNECTED', color: Colors.green[200])));

      _channel.stream.listen((data) => setState(() => _messages.add(Message(
            text: 'Received: $data',
            color: Colors.blue[50],
          ))));

      _webSocketConnection = WebSocketConnection.connected;
    }
  }

  void _disconnect() {
    if (_webSocketConnection == WebSocketConnection.connected) {
      setState(() =>
          _messages.add(Message(text: 'DISCONNECTED', color: Colors.red[200])));

      _channel.sink.close();

      _webSocketConnection = WebSocketConnection.disconnected;
    }
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty &&
        _webSocketConnection == WebSocketConnection.connected) {
      _channel.sink.add(_messageController.text);

      _messages.add(Message(
        text: 'Sent: ${_messageController.text}',
        color: Colors.white,
      ));

      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _connectionController.dispose();
    _messageController.dispose();
    _channel.sink.close();

    super.dispose();
  }
}
