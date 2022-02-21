library flutter_speedtest;

import 'dart:math';

import 'package:dio/dio.dart';
import 'package:tuple/tuple.dart';

typedef DoneCallback = void Function(double transferRate);

typedef ProgressCallback = void Function(
  double percent,
  double transferRate,
);
typedef ProgressResponseCallback = void Function(
  int responseTime,
  int jitter,
);

typedef ErrorCallback = void Function(String errorMessage);

/// [FlutterSpeedtest] is a singleton class that provides assess to Speedtest events
class FlutterSpeedtest {
  final _dio = Dio();

  late Tuple3<ErrorCallback, ProgressCallback, DoneCallback> _callbacks;

  // static final FlutterSpeedtest _instance = FlutterSpeedtest._();

  // factory FlutterSpeedtest() {
  //   return _instance;
  // }

  // FlutterSpeedtest._();

  Future<void> downloadProgress({
    required String url,
    // Function(double)? onProgress,
    required ProgressCallback onProgress,
    required ErrorCallback onError,
  }) async {
    try {
      print(url);
      final sendDate = DateTime.now().millisecondsSinceEpoch;
      // if (onProgress != null) onProgress(3);
      await _dio.get(
        url,
        onReceiveProgress: (int received, int total) {
          print(total);
          // showDownloadProgress(received, total, sendDate);
          if (total != -1) {
            // if (onProgress != null) onProgress(5);
            int t = DateTime.now().millisecondsSinceEpoch - sendDate;

            int totDownloaded = 0;

            totDownloaded += received;

            double bonusT = 0;

            double speed = totDownloaded / ((t < 100 ? 100 : t) / 1000.0);

            double b = (2.5 * speed) / 100000.0;
            bonusT += b > 200 ? 200 : b;

            // double progress = (t + bonusT) / 15 * 1000;

            speed = (speed * 8 * 1.06) / 1000000.0;
            print(speed);

            // _callbacks = Tuple3(onError, onProgress);

            onProgress(
              (received / total * 100),
              speed,
            );

            // if (onProgress != null) onProgress(speed);
            // debugPrint(speed);
          }
        },
        //Received data with List<int>
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      ).catchError((onError) {
        print(onError.toString());
      }).whenComplete(() => print('complet'));
      // debugPrint(response.statusMessage);
    } on DioError catch (e) {
      print('dfsdfsfd');
      onError(e.error.toString());
    }
  }

  Future<void> uploadProgress({
    required String url,
    // Function(double)? onProgress,
    required ProgressCallback onProgress,
    required ErrorCallback onError,
  }) async {
    try {
      final sendDate = DateTime.now();
      double speeds = 0;

      await _dio.post(
        url,
        data: {
          'randomDataString': getRandomString(1500000),
        },
        onSendProgress: (int received, int total) {
          // showUploadProgress(received, total, sendDate);
          if (total != -1) {
            int t = DateTime.now().millisecondsSinceEpoch -
                sendDate.millisecondsSinceEpoch;

            double bonusT = 0;

            int totUploaded = 0;
            totUploaded += received;

            double speed = totUploaded / ((t < 100 ? 100 : t) / 1000.0);

            double b = (2.5 * speed) / 100000.0;
            bonusT += b > 200 ? 200 : b;

            double progress = (t + bonusT) / 15 * 1000;
            speed = (speed * 8 * 1.06) / 1000000.0;

            onProgress(
              (received / total * 100),
              speed,
            );
          }
        },
        //Received data with List<int>
        options: Options(
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );

      // print(response.headers);
    } on DioError catch (e) {
      onError(e.error.toString());
      print(e);
    }
  }

  Future<void> getResponseTime({
    required String url,
    required ProgressResponseCallback onProgress,
  }) async {
    List<int> pingResult = [];
    for (var i = 0; i < 10; i++) {
      var ping = await testResponse(url);
      // print(ping);
      pingResult.add(ping);
    }
    print('=====');
    print(pingResult);
    int sum = pingResult.fold(0, (p, c) => p + c);
    print('jumlah nya : $sum');
    // setState(() {
    var responseTime = sum ~/ 10;
    // });

    /// calculate jitter
    ///
    int jitter = _calculateJitter(pingResult);

    onProgress(responseTime, jitter);
  }

  int _calculateJitter(List<int> pingResult) {
    final jitter = <int>[];
    for (var i = 0; i < pingResult.length; i++) {
      if (i < pingResult.length - 1) {
        if (pingResult[i] < pingResult[i + 1]) {
          print('++++');
          print((pingResult[i + 1]) - pingResult[i]);
          jitter.add((pingResult[i] + 1) - pingResult[i]);
        } else {
          jitter.add(pingResult[i] - (pingResult[i + 1]));
          print('====');
          print(pingResult[i] - (pingResult[i + 1]));
        }
      } else {
        print('lol');
      }
    }

    // print(jitter);
    int sumJitter = jitter.fold(0, (p, c) => p + c);
    // print('jumlah nya : $sumJitter');
    // print('rata jitter nya : ${sumJitter ~/ jitter.length - 1}');

    // setState(() {
    var resultJitter = sumJitter ~/ (jitter.length - 1);
    return resultJitter;
    // });
  }

  Future<int> testResponse(String url) async {
    try {
      final sendDate = DateTime.now();

      await _dio.head(
        url,

        //Received data with List<int>
        options: Options(
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      var receiveDate = DateTime.now();
      var duration = receiveDate.difference(sendDate).inMilliseconds;

      // setState(() {
      //   responseTime = '${duration.toStringAsFixed(2)} ms';
      // });

      // print(response.headers);
      return duration;
    } catch (e) {
      print(e);
      return 0;
    }
  }
}

class SpeedtestEvent {}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
