import 'package:audioplayers/audioplayers.dart';

class audioPlayerWithNote extends AudioPlayer {
  int note = 0;
  audioPlayerWithNote({PlayerMode? mode, required String playerId})
      : super(mode: mode!, playerId: playerId);
}
