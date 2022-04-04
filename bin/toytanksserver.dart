import 'dart:io';
import 'server.dart';

void main(List<String> arguments) async {
  ///initial procedures
  print('Toytanks server');

  //creating WebSocket Server
  startServer();
}

void handleData(Map<String, dynamic> decoded, WebSocket fromWS) {
  try {
    print(decoded);
  } catch (e) {
    print(e);
  }
}

///if client connection is gone
void handleOnDone(WebSocket _ws) {
  print('onDone: ${_ws.closeCode}');
  print(users.length);
  try {
    users.removeWhere((_user) => _user.ws == _ws); //remove from List of users

  } catch (e) {
    print(e);
  }
  print(users.length);
}
