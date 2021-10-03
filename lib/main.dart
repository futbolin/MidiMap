import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'controller.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<String> _setupSubscription;
  final MidiCommand _midiCommand = MidiCommand();

  @override
  void initState() {
    super.initState();
    _setupSubscription = _midiCommand.onMidiSetupChanged!.listen((data) {
      print("setup changed $data");
      switch (data) {
        case "deviceFound":
          setState(() {});
          break;
        // case "deviceOpened":
        //   break;
        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    _setupSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('MidiMap'),
        ),
        body: Center(
            child: FutureBuilder(
                future: _midiCommand.devices,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    var devices = snapshot.data as List<MidiDevice>;
                    return ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        MidiDevice device = devices[index];
                        return ListTile(
                          title: Text(
                            device.name,
                          ),
                          subtitle: Text(
                              "Inps:${device.inputPorts.length} Outps:${device.outputPorts.length} Note:"),
                          trailing: device.type == "BLE"
                              ? const Icon(Icons.bluetooth)
                              : const Icon(Icons.adjust_sharp),
                          onTap: () {
                            _midiCommand.onMidiDataReceived;
                          },
                          onLongPress: () {
                            _midiCommand.connectToDevice(device);

                            Navigator.of(context).push(MaterialPageRoute<Null>(
                              builder: (_) => Controller(device),
                            ));
                          },
                        );
                      },
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                })),
      ),
    );
  }
}
