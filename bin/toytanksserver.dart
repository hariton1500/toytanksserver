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
  print(coded);
  try {
    Map<String, dynamic> decoded = jsonDecode(coded);
    switch (decoded.keys.toList()[0]) {
      case 'handshake':
        break;
      case 'wantGame2x2':
        User _user = users.firstWhere((_u) => _u.ws == fromWS);
        game2x2.add(_user);
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
        game2x2.add(_user);
        if (game3x3.length >= 6) {
          startGame3x3(game3x3);
          game2x2.removeRange(0, 6);
        } else {
          sendGroupUsers(
              game3x3, jsonEncode({'userJoinedGame': game3x3.last.name}));
        }
        break;
      case 'wantGame4x4':
        User _user = users.firstWhere((_u) => _u.ws == fromWS);
        game2x2.add(_user);
        if (game4x4.length >= 8) {
          startGame4x4(game4x4);
          game2x2.removeRange(0, 8);
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

  } catch (e) {
    print(e);
  }
  print(users.length);
}
