import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:permission_and_appcycle/main.dart';
import 'package:permission_and_appcycle/services/permission_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late StreamController<PermissionStatus> _permissionStatusStream;
  late StreamController<AppLifecycleState> _appCycleStateStream;
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _permissionStatusStream = StreamController<PermissionStatus>();
    _appCycleStateStream = StreamController<AppLifecycleState>();
    _listener = AppLifecycleListener(
      onStateChange: _onStateChange,
      onResume: _onResume,
      onInactive: _onInactive,
      onHide: _onHide,
      onShow: _onShow,
      onPause: _onPause,
      onRestart: _onRestart,
      onDetach: _onDetach,
    );
    _appCycleStateStream.sink.add(SchedulerBinding.instance.lifecycleState!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkPermissionAndListenLocation();
    });
  }

  void _onStateChange(AppLifecycleState state) =>
      _appCycleStateStream.sink.add(state);

  void _onResume() {
    log('onResume');
    if (PermissionProvider.permissionDialogRoute != null &&
        PermissionProvider.permissionDialogRoute!.isActive) {
      Navigator.of(globalNavigatorKey.currentContext!)
          .removeRoute(PermissionProvider.permissionDialogRoute!);
    }
    Future.delayed(const Duration(milliseconds: 250), () async {
      checkPermissionAndListenLocation();
    });
  }

  void _onInactive() => log('onInactive');

  void _onHide() => log('onHide');

  void _onShow() => log('onShow');

  void _onPause() => log('onPause');

  void _onRestart() => log('onRestart');

  void _onDetach() => log('onDetach');

  @override
  void dispose() {
    _listener.dispose();
    _permissionStatusStream.close();
    _appCycleStateStream.close();
    super.dispose();
  }

  void checkPermissionAndListenLocation() {
    PermissionProvider.handleLocationPermission().then((_) {
      _permissionStatusStream.sink.add(PermissionProvider.locationPermission);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Expanded(
          child: Center(
            child: StreamBuilder<PermissionStatus>(
              stream: _permissionStatusStream.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Display a loading indicator when waiting for data
                } else if (snapshot.hasError) {
                  return Text(
                      'Error: ${snapshot.error}'); // Display an error message if an error occurs
                } else if (!snapshot.hasData) {
                  return const Text(
                      'No Data Available'); // Display a message when no data is available
                } else {
                  return Text(
                    'Location Service: ${PermissionProvider.isServiceOn ? "On" : "Off"}\n${snapshot.data}',
                    style: const TextStyle(fontSize: 24),
                  );
                }
              },
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: StreamBuilder<AppLifecycleState>(
              stream: _appCycleStateStream.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Display a loading indicator when waiting for data
                } else if (snapshot.hasError) {
                  return Text(
                      'Error: ${snapshot.error}'); // Display an error message if an error occurs
                } else if (!snapshot.hasData) {
                  return const Text(
                      'No data available'); // Display a message when no data is available
                } else {
                  return Text(
                    '${snapshot.data}',
                    style: const TextStyle(fontSize: 24),
                  );
                }
              },
            ),
          ),
        ),
      ],
    ));
  }
}
