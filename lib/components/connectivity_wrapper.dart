import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pamfurred/components/empty_list_widget.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({required this.child, super.key});

  @override
  ConnectivityWrapperState createState() => ConnectivityWrapperState();
}

class ConnectivityWrapperState extends State<ConnectivityWrapper> {
  late ConnectivityResult _connectionStatus;
  late Connectivity _connectivity;
  bool isConnected = true;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _checkConnectivity();
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectionStatus = result;
        isConnected = _connectionStatus != ConnectivityResult.none;
      });
    });
  }

  Future<void> _checkConnectivity() async {
    _connectionStatus = await _connectivity.checkConnectivity();
    setState(() {
      isConnected = _connectionStatus != ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isConnected
        ? widget.child
        : Scaffold(
            body: Center(
              child: emptyListWidget(Icons.signal_wifi_off, 'No internet',
                  'Please connect to the internet.'),
            ),
          );
  }
}
