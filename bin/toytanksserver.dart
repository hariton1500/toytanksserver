import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'helpers.dart';
import 'models.dart';
import 'server.dart';

//create games types identificators
Map<String, List<User>> gameQuers = {
  '1x1': [],
  '2x2': [],
  '3x3': [],
  '4x4': []
};
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

  //creating fps process
  Timer.periodic(Duration(milliseconds: 1000 ~/ 30), (t) {
    for (var game in games) {
      //print(game.participants);
      game.tick(t);
    }
  });
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
      case 'wantGame':
        User _user = users.firstWhere((_u) => _u.ws == fromWS);
        String gameType = decoded['wantGame'].toString();
        print('user ${_user.name} wants enter game $gameType');
        for (var __user in gameQuers[gameType]!) {
          _user.send(jsonEncode({'userJoinedGame': __user.name}));
        }
        gameQuers[gameType]!.add(_user);
        print(
            'number of users in $gameType room is: ${gameQuers[gameType]!.length}');
        int gameTypeUsersNumber = int.parse(gameType[0]) * 2;
        if (gameQuers[gameType]!.length >= gameTypeUsersNumber) {
          startGame(gameQuers[gameType]!);
          gameQuers[gameType]!.removeRange(0, gameTypeUsersNumber);
        } else {
          sendGroupUsers(gameQuers[gameType]!,
              jsonEncode({'userJoinedGame': gameQuers[gameType]!.last.name}));
        }
        break;
      case 'playerAction':
        User _user = users.firstWhere((_u) => _u.ws == fromWS);
        Game _game =
            games.firstWhere((game) => game.participants.contains(_user));
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
  try {
    User _user = users.firstWhere((__user) => __user.ws == _ws);
    print('Disconnected user ${_user.name} from ip ${_user.ip}');
    for (var game in games) {
      game.participants.remove(_user);
    }
    games.removeWhere((game) => game.participants.isEmpty);
    for (var _users in gameQuers.values) {
      _users.remove(_user);
    }
    users.remove(_user); //remove from List of users
  } catch (e) {
    print(e);
  }
}
