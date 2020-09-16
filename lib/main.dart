import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

enum WebSocketConnection { connected, disconnected }

class Message {
  final String text;
  final Color color;

  Message({@required this.text, @required this.color});
}

void main() {
  runApp(WebSocketDemo());
}

class WebSocketDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'WebSocket Demo';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: MyHomePage(title: title),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  IOWebSocketChannel _channel;
  final TextEditingController _connectionController =
      TextEditingController(text: 'ws://echo.websocket.org');
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  WebSocketConnection _webSocketConnection = WebSocketConnection.disconnected;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: _getMessages(),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: RaisedButton(
              child: Text(
                'CLEAR MESSAGES',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () => setState(() => _messages.clear()),
            ),
          ),
          TextField(
            controller: _connectionController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Connect to WebSocket',
            ),
            style: TextStyle(fontSize: 20),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8),
                child: RaisedButton(
                  child: Text(
                    'CONNECT',
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () => _connect(_connectionController.text),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: RaisedButton(
                  child: Text(
                    'DISCONNECT',
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: _disconnect,
                ),
              ),
            ],
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
                  child: RaisedButton(
                    child: Text(
                      'SEND',
                      style: TextStyle(fontSize: 20),
                    ),
                    onPressed: _sendMessage,
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

  ListView _getMessages() {
    List<ListTile> _messageListTiles = [];

    for (Message message in _messages) {
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

  @override
  void dispose() {
    _connectionController.dispose();
    _messageController.dispose();
    _channel.sink.close();
    super.dispose();
  }
}
