import 'models.dart';
import 'toytanksserver.dart';

void sendGroupUsers(List<User> toUsers, String message) {
  //jsonEncode({'userJoinedGame': game2x2.last.name}));
  for (var user in toUsers) {
    print('sending join mess to user: ${user.name} to ip: ${user.ip}');
    user.send(message);
  }
}

void startGame(List<User> participants) {
  games.add(Game(forUsers: participants));
}

void startGame2x2(List<User> participants) {
  games.add(Game(forUsers: participants));
}

void startGame3x3(List<User> participants) {
  games.add(Game(forUsers: participants));
}

void startGame4x4(List<User> participants) {
  games.add(Game(forUsers: participants));
}
