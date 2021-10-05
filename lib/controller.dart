import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'dart:async';

class Controller extends StatefulWidget {
  MidiDevice device;
  Controller(this.device);
  AudioPlayer player = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
  int transpose = 0;
  bool crash = false;

  @override
  _ControllerState createState() => _ControllerState();

  Future<AudioPlayer> _playFile(
      int nota, AudioCache cache, double volume) async {
    player = await cache.play((nota + transpose).toString() + ".wav",
        mode: PlayerMode.LOW_LATENCY);
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
          player = widget._playFile(
              receivedMidi[1], cache, receivedMidi[2] * 0.70 / 100);
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
        if (widget.crash) {
          notes.clear();
          for (int i = 0; i < audioPlayers.length; i++) {
            audioPlayers[i].then((value) {
              value.setVolume(0);
            });
          }
          audioPlayers.clear();
          widget.crash = false;
          ;
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
        child: Column(
          children: [
            SizedBox(
              height: 150,
            ),
            Row(
              children: [
                Center(child: Text("Transpose:")),
              ],
            ),
            Row(
              children: [
                Center(
                  child: Column(
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            widget.transpose++;
                          },
                          child: Text("+1")),
                      SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            widget.transpose--;
                          },
                          child: Text("-1")),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        widget.crash = false;
                      });
                      ;
                    },
                    child: Text("Crash"),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
