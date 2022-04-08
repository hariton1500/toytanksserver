import 'dart:convert';
import 'dart:io';
import 'helpers.dart';
import 'models.dart';
import 'server.dart';

//create games types identificators
List<User> game2x2 = [];
List<User> game3x3 = [];
List<User> game4x4 = [];

//create list of running games
List<Game> games = [];

void main(List<String> arguments) async {
  ///initial procedures
  print('Toytanks server');

  //creating WebSocket Server
  startServer();
}

void handleData(String coded, WebSocket fromWS) {
  //print(coded);
  try {
    Map<String, dynamic> decoded = jsonDecode(coded);
    switch (decoded.keys.toList()[0]) {
      case 'handshake':
        User _user = users.firstWhere((_u) => _u.ws == fromWS);
        _user.loadHandshake(decoded);
        break;
      case 'wantGame2x2':
        User _user = users.firstWhere((_u) => _u.ws == fromWS);
        print('user ${_user.name} wants enter game 2x2');
        game2x2.add(_user);
        print('number of users in 2x2 room is: ${game2x2.length}');
        if (game2x2.length >= 4) {
          startGame2x2(game2x2);
          game2x2.removeRange(0, 4);
        } else {
          sendGroupUsers(
              game2x2, jsonEncode({'userJoinedGame': game2x2.last.name}));
        }
        break;
      case 'wantGame3x3':
        User _user = users.firstWhere((_u) => _u.ws == fromWS);
        print('user ${_user.name} wants enter game 3x3');
        game3x3.add(_user);
        print('number of users in 3x3 room is: ${game3x3.length}');
        if (game3x3.length >= 6) {
          startGame3x3(game3x3);
          game3x3.removeRange(0, 6);
        } else {
          sendGroupUsers(
              game3x3, jsonEncode({'userJoinedGame': game3x3.last.name}));
        }
        break;
      case 'wantGame4x4':
        User _user = users.firstWhere((_u) => _u.ws == fromWS);
        print('user ${_user.name} wants enter game 4x4');
        game4x4.add(_user);
        print('number of users in 4x4 room is: ${game4x4.length}');
        if (game4x4.length >= 8) {
          startGame4x4(game4x4);
          game4x4.removeRange(0, 8);
        } else {
          sendGroupUsers(
              game4x4, jsonEncode({'userJoinedGame': game4x4.last.name}));
        }
        break;
      case 'playerAction':
        User _user = users.firstWhere((_u) => _u.ws == fromWS);
        Game _game =
            games.firstWhere((game) => game.participants!.contains(_user));
        _game.playerAction(decoded['playerAction'], _user);
        break;
      default:
    }
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
    game2x2.removeWhere((_user) => _user.ws == _ws);
    game3x3.removeWhere((_user) => _user.ws == _ws);
    game4x4.removeWhere((_user) => _user.ws == _ws);
  } catch (e) {
    print(e);
  }
  print(users.length);
}
