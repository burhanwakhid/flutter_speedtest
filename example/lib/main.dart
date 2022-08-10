import 'package:flutter/material.dart';
import 'package:flutter_speedtest/flutter_speedtest.dart';

void main() {
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
    baseUrl: 'http://speedtest.jaosing.com:8080',
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
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Download: $_progressDownload'),
          Text('upload: $_progressUpload'),
          Text('Ping: $_ping'),
          Text('Jitter: $_jitter'),
          ElevatedButton(
            onPressed: () {
              _speedtest.getDataspeedtest(
                downloadOnProgress: ((percent, transferRate) {
                  setState(() {
                    _progressDownload = transferRate;
                  });
                }),
                uploadOnProgress: ((percent, transferRate) {
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
              );
            },
            child: const Text('test download'),
          ),
          ElevatedButton(
            onPressed: () {
              // _speedtest.uploadProgress(
              //   url:
              //       'http://speedtest-sby.natanetwork.co.id:8080/speedtest/upload.php',
              //   onProgress: (percent, transferRate) {
              //     setState(() {
              //       _progressUpload = transferRate;
              //     });
              //   },
              //   onError: (errorMessage) {},
              // );
            },
            child: const Text('test upload'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              // _speedtest.getResponseTime(
              //   url:
              //       'http://speedtest-sby.natanetwork.co.id:8080/speedtest/ping',
              //   onProgress: (responseTime, jitter) {
              //     setState(() {
              //       _ping = responseTime;
              //       _jitter = jitter;
              //     });
              //   },
              // )
            },
            child: const Text('test ping'),
          ),
        ],
      )),
    );
  }
}
