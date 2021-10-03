import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'dart:async';

class Controller extends StatefulWidget {
  MidiDevice device;
  static AudioCache player = AudioCache(prefix: 'assets/sounds/');
  Controller(this.device);

  AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);

  @override
  _ControllerState createState() => _ControllerState();
}

class _ControllerState extends State<Controller> {
  late StreamSubscription<MidiPacket> _dataSubscription;
  final MidiCommand _midiCommand = MidiCommand();
  late Uint8List receivedMidi;
  int push = 144;
  int pull = 128;

  @override
  void initState() {
    super.initState();
    _dataSubscription = _midiCommand.onMidiDataReceived!.listen((event) {
      setState(() {
        receivedMidi = event.data;
        if (receivedMidi[0] == push) {
          widget.audioPlayer.setVolume(receivedMidi[2] / 1000);
          Controller.player.play('a4.wav');
        } else {
          receivedMidi[0] = 666;
          widget.audioPlayer.stop();
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
          ],
        ),
      ),
    );
  }
}
