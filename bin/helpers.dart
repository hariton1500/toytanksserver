import 'models.dart';
import 'toytanksserver.dart';

void sendGroupUsers(List<User> toUsers, String message) {
  //jsonEncode({'userJoinedGame': game2x2.last.name}));
  for (var user in toUsers) {
    user.send(message);
  }
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