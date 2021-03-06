import 'dart:io'
    show
        HttpRequest,
        HttpServer,
        InternetAddress,
        WebSocket,
        WebSocketTransformer;
//import 'dart:convert' show json;

import 'models.dart';
import 'toytanksserver.dart';

//import 'dart:async' show Timer;
List<User> users = [];
startServer() {
  HttpServer.bind(InternetAddress.anyIPv4, 8000).then((HttpServer server) {
    print('[+]WebSocket listening at -- ws://localhost:8000/');
    server.listen((HttpRequest request) {
      WebSocketTransformer.upgrade(request).then((WebSocket ws) {
        //return ws;
        //print(request.connectionInfo?.localPort.toString());
        //print(request.connectionInfo?.remotePort.toString());
        print(request.connectionInfo?.remoteAddress.host.toString());
        User user = User();
        user.ws = ws;
        user.ip = request.connectionInfo?.remoteAddress.address;
        user.port = request.connectionInfo?.remotePort;
        users.add(user);
        ws.listen(
          (data) {
            print('\t\t${request.connectionInfo?.remoteAddress}');
            print(data);
            handleData(data, ws);
          },
          onDone: () => handleOnDone(ws),
          onError: (err) => print('[!]Error -- ${err.toString()}'),
          cancelOnError: true,
        );
      }, onError: (err) {
        return err.toString();
      }); //print('[!]Error -- ${err.toString()}'));
    }, onError: (err) {
      return err.toString();
    }); //=> print('[!]Error -- ${err.toString()}'));
  }, onError: (err) {
    return err.toString();
  }); //=> print('[!]Error -- ${err.toString()}'));
}
