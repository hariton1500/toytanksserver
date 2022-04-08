import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:forge2d/forge2d.dart' hide Timer;

import 'helpers.dart';

class User {
  WebSocket? ws;
  String? email;
  String? name;
  String? ip;
  int? port;
  bool? enteredToRoom;

  void send(String data) {
    ws?.add(data);
  }

  void loadHandshake(Map<String, dynamic> decoded) {
    try {
      print('loading new user handshake data');
      print('decoded: $decoded');
      //Map<String, dynamic> data = decoded['handshake'];
      //print('data: $data');
      name = decoded['handshake']['name'].toString();
      print('get name: $name');
      email = decoded['handshake']['email'].toString();
      print('get email: $email');
    } catch (e) {
      print(e);
    }
  }
}

class GameMap {
  int? uid;
  List<String>? lines;

  GameMap({required int id}) {
    try {
      var file = File('maps/map$id.txt');
      lines = file.readAsLinesSync();
    } catch (e) {
      print(e);
    }
  }
}

class Game {
  int? uid;
  List<User>? participants;
  GameMap? gameMap;
  var timeStep = 1 / 60;
  World world = World(Vector2.zero());
  Map<User, Body> userBodiesMap = {};

  Game({required List<User> forUsers}) {
    participants = forUsers;
    uid = DateTime.now().microsecondsSinceEpoch;
    sendGroupUsers(forUsers, jsonEncode({'map': GameMap(id: 1).lines}));
    for (var user in forUsers) {
      user.send(jsonEncode({'yourIndex': forUsers.indexOf(user) + 1}));
    }
    List<Body> players = [];
    List<Body> walls = [];
    BodyDef wallBodyDef = BodyDef();
    BodyDef playerBodyDef = BodyDef();
    playerBodyDef.type = BodyType.dynamic;

    PolygonShape wallBox = PolygonShape();
    wallBox.setAsBox(10, 10, Vector2.zero(), 0);
    PolygonShape playerBox = PolygonShape();
    playerBox.setAsBoxXY(10, 5);

    gameMap = GameMap(id: 1);
    for (var i = 0; i < gameMap!.lines!.length; i++) {
      String _row = gameMap!.lines![i];
      for (var j = 0; j < _row.length; j++) {
        switch (_row[j]) {
          case '=': //border
            wallBodyDef.position = Vector2(i.toDouble(), j.toDouble());
            Body _body = world.createBody(wallBodyDef);
            _body.createFixtureFromShape(wallBox);
            walls.add(_body);
            break;
          case '1': //player 1
            playerBodyDef.position = Vector2(i.toDouble(), j.toDouble());
            Body _body = world.createBody(playerBodyDef);
            _body.createFixtureFromShape(playerBox);
            players.add(_body);
            userBodiesMap[participants![0]] = _body;
            break;
          default:
        }
      }
    }
    Timer.periodic(Duration(milliseconds: 1000 ~/ 60), (timer) => tick());
  }

  void tick() {
    world.stepDt(timeStep);
    for (var user in participants!) {
      user.send(json.encode(userBodiesMap[user]!.position.toString()));
    }
  }

  void playerAction(String actionCoded, User user) {
    try {
      Map<String, dynamic> decodedAction = jsonDecode(actionCoded);
      switch (decodedAction['key']) {
        case 'Up':
          world.bodies
              .firstWhere((body) => userBodiesMap.containsValue(body))
              .applyAngularImpulse(1);
          break;
        default:
      }
    } catch (e) {
      print(e);
    }
  }
}
