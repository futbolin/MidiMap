import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'dart:async';

class Controller extends StatefulWidget {
  MidiDevice device;
  Controller(this.device);
  AudioPlayer player = AudioPlayer(mode: PlayerMode.LOW_LATENCY);

  @override
  _ControllerState createState() => _ControllerState();

  Future<AudioPlayer> _playFile(
      String nota, AudioCache cache, double volume) async {
    player = await cache.play(nota, mode: PlayerMode.LOW_LATENCY);
    player.setVolume(volume);
    return player;
  }
}

class _ControllerState extends State<Controller> {
  late StreamSubscription<MidiPacket> _dataSubscription;
  final MidiCommand _midiCommand = MidiCommand();
  late Uint8List receivedMidi;

  @override
  void initState() {
    late List<Future<AudioPlayer>> audioPlayers = [];
    List<int> notes = [];
    AudioCache cache = AudioCache(prefix: 'assets/sounds/');

    late Future<AudioPlayer> player;

    super.initState();
    _dataSubscription = _midiCommand.onMidiDataReceived!.listen((event) {
      setState(() {
        receivedMidi = event.data;

        if (receivedMidi[2] >= 1) {
          player = widget._playFile(receivedMidi[1].toString() + ".wav", cache,
              receivedMidi[2] * 0.78 / 100);
          audioPlayers.add(player);
          notes.add(receivedMidi[1]);
        } else {
          if (notes.contains(receivedMidi[1])) {
            audioPlayers
                .elementAt(notes.indexOf(receivedMidi[1]))
                .then((value) {
              value.setVolume(0);
            });
            audioPlayers.removeAt(notes.indexOf(receivedMidi[1]));
            notes.remove(receivedMidi[1]);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _dataSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          children: [
            Text(receivedMidi[0].toString()),
            SizedBox(
              width: 20,
            ),
            Text(receivedMidi[1].toString()),
            SizedBox(
              width: 20,
            ),
            Text(receivedMidi[2].toString()),
            SizedBox(
              width: 20,
            ),
            Text(receivedMidi.toString()),
            SizedBox(
              width: 20,
            ),
          ],
        ),
      ),
    );
  }
}
