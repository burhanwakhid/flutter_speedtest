import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_speedtest/flutter_speedtest.dart';

void main() {
  // HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _speedtest = FlutterSpeedtest(
    baseUrl:
        'https://speedtest-ookla.sman4tegal.sch.id.prod.hosts.ooklaserver.net:8080',
    pathDownload: '/download',
    pathUpload: '/upload',
    pathResponseTime: '/ping',
  );

  double _progressDownload = 0;
  double _progressUpload = 0;

  int _ping = 0;
  int _jitter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flutter Speedtest',
        ),
      ),
      body: Center(
          child: ListView(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Download: $_progressDownload'),
          Text('upload: $_progressUpload'),
          Text('Ping: $_ping'),
          Text('Jitter: $_jitter'),
          ElevatedButton(
            onPressed: () {
              _speedtest.getDataspeedtest(
                downloadOnProgress: ((percent, transferRate) {
                  print(transferRate);
                  setState(() {
                    _progressDownload = transferRate;
                  });
                }),
                uploadOnProgress: ((percent, transferRate) {
                  print(transferRate);
                  setState(() {
                    _progressUpload = transferRate;
                  });
                }),
                progressResponse: ((responseTime, jitter) {
                  setState(() {
                    _ping = responseTime;
                    _jitter = jitter;
                  });
                }),
                onError: ((errorMessage) {
                  // print(errorMessage);
                }),
                onDone: () => debugPrint('done'),
              );
            },
            child: const Text('test download'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: ListTile(
              title: Text('data'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: ListTile(
              title: Text('data'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: ListTile(
              title: Text('data'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: ListTile(
              title: Text('data'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: ListTile(
              title: Text('data'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: ListTile(
              title: Text('data'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: ListTile(
              title: Text('data'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: ListTile(
              title: Text('data'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: ListTile(
              title: Text('data'),
            ),
          ),
        ],
      )),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
