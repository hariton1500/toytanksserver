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
  Body? body;
  Vector2? position, newPosition;

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
  List<User> participants = [];
  GameMap? gameMap;
  var timeStep = 1 / 30;
  World world = World(Vector2.zero());
  Map<User, Body> userBodiesMap = {};

  Game({required List<User> forUsers}) {
    print('new game generating');
    participants.addAll(forUsers);
    print('players: ${participants.map((e) => e.name).toList()}');
    uid = DateTime.now().microsecondsSinceEpoch;
    print('sending map');
    sendGroupUsers(participants, jsonEncode({'map': GameMap(id: 1).lines}));
    print('sending indexes');
    for (var user in participants) {
      user.send(jsonEncode({'yourIndex': participants.indexOf(user) + 1}));
    }
    print('creating world bodies');
    List<Body> players = [];
    List<Body> walls = [];
    BodyDef wallBodyDef = BodyDef();
    BodyDef playerBodyDef = BodyDef();
    playerBodyDef.type = BodyType.dynamic;

    PolygonShape wallBox = PolygonShape();
    wallBox.setAsBox(20, 20, Vector2.zero(), 0);
    PolygonShape playerBox = PolygonShape();
    playerBox.setAsBoxXY(10, 20);

    gameMap = GameMap(id: 1);
    for (var i = 0; i < gameMap!.lines!.length; i++) {
      String _row = gameMap!.lines![i];
      for (var j = 0; j < _row.length; j++) {
        switch (_row[j]) {
          case '=': //border
            wallBodyDef.position =
                Vector2((i * 20 + 10).toDouble(), (j * 20 + 10).toDouble());
            Body _body = world.createBody(wallBodyDef);
            _body.createFixtureFromShape(wallBox);
            _body.setType(BodyType.static);
            walls.add(_body);
            break;
          case '1': //player 1
            playerBodyDef.position =
                Vector2((i * 20 + 10).toDouble(), (j * 20 + 10).toDouble());
            print('playerBodyDef = ${playerBodyDef.position}');
            Body _body = world.createBody(playerBodyDef);
            _body.createFixtureFromShape(playerBox, 10);
            _body.setType(BodyType.dynamic);
            _body.setActive(true);
            print('player1 position: ${_body.position}');
            //_body.setMassData(MassData.copy());
            players.add(_body);
            participants[0].body = _body;
            break;
          case '2': //player 2
            playerBodyDef.position =
                Vector2((i * 20 + 10).toDouble(), (j * 20 + 10).toDouble());
            Body _body = world.createBody(playerBodyDef);
            _body.createFixtureFromShape(playerBox, 1);
            _body.setType(BodyType.dynamic);
            _body.setActive(true);
            print('player2 position: ${_body.position}');
            players.add(_body);
            participants[1].body = _body;
            break;
          default:
        }
      }
    }
  }

  void tick(Timer t) {
    //print(participants);
    if (participants.isEmpty) {
      t.cancel();
    }
    world.stepDt(timeStep);
    try {
      for (var user in participants) {
        //user.newPosition = world.bodies.firstWhere((_body) => user.body == _body).position;
        if (true) {
          //user.body!.position != user.position) {
          //print('sending new pos = ${user.body!.position} to ${user.name}');
          for (var _user in participants) {
            user.send(jsonEncode({
              'position': {
                'index': participants.indexOf(_user) + 1,
                'x': _user.body!.position.x,
                'y': _user.body!.position.y,
                'angle': _user.body!.angle
              }
            }));
            _user.position = _user.body!.position;
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void playerAction(Map<String, dynamic> action, User user) {
    try {
      //Map<String, dynamic> decodedAction = jsonDecode(actionCoded);
      Map<String, dynamic> key = action['key'];
      //print('key is $key');
      switch (key.keys.toList()[0]) {
        case 'speed':
          //print('possition: ' + user.body!.position.toString());
          double num = key['speed'].toDouble();
          //print(num);
          Vector2 impulse = Vector2(-num * 10, -num * 10);
          //print(impulse);
          //print(user.body!.linearVelocity);
          user.body!.applyLinearImpulse(impulse, wake: true);
          break;
        case 'leftRight':
          double num = key['leftRight'].toDouble();
          user.body!.applyTorque(num * 100);
          break;
        default:
      }
    } catch (e) {
      print(e);
    }
  }
}
