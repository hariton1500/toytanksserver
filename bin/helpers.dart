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
  //Game _game = Game(forUsers: participants);
  games.add(Game(forUsers: participants));
}
