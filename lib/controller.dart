import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'dart:async';
import 'package:midimap/audio_player_with_note.dart';

class Controller extends StatefulWidget {
  MidiDevice device;
  Controller(this.device);
  AudioPlayer player = AudioPlayer(mode: PlayerMode.LOW_LATENCY);

  @override
  _ControllerState createState() => _ControllerState();

  Future<AudioPlayer> _playFile(String nota, AudioCache cache) async {
    player = await cache.play(nota);
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
    cache.load('43.wav');
    cache.load('44.wav');
    cache.load('45.wav');
    cache.load('46.wav');
    cache.load('47.wav');
    cache.load('48.wav');
    cache.load('49.wav');
    cache.load('50.wav');
    cache.load('51.wav');
    cache.load('52.wav');
    cache.load('53.wav');
    cache.load('54.wav');
    late Future<AudioPlayer> player;

    super.initState();
    _dataSubscription = _midiCommand.onMidiDataReceived!.listen((event) {
      setState(() {
        receivedMidi = event.data;

        if (receivedMidi[2] >= 1) {
          player = widget._playFile(receivedMidi[1].toString() + ".wav", cache);
          audioPlayers.add(player);
          notes.add(receivedMidi[1]);
        } else {
          if (notes.contains(receivedMidi[1])) {
            audioPlayers
                .elementAt(notes.indexOf(receivedMidi[1]))
                .then((value) {
              value.stop();
            });
            audioPlayers.removeAt(notes.indexOf(receivedMidi[1]));
            notes.remove(receivedMidi[1]);
            ;
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
