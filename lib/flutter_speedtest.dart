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

  Future<void> downloadProgress({
    required String url,
    // Function(double)? onProgress,
    required ProgressCallback onProgress,
    required ErrorCallback onError,
  }) async {
    try {
      final sendDate = DateTime.now().millisecondsSinceEpoch;

      await _dio
          .get(
            url,
            onReceiveProgress: (int received, int total) {
              if (total != -1) {
                // if (onProgress != null) onProgress(5);
                int t = DateTime.now().millisecondsSinceEpoch - sendDate;

                int totDownloaded = 0;

                totDownloaded += received;

                double bonusT = 0;

                double speed = totDownloaded / ((t < 100 ? 100 : t) / 1000.0);

                double b = (2.5 * speed) / 100000.0;
                bonusT += b > 200 ? 200 : b;

                speed = (speed * 8 * 1.06) / 1048576.0;

                onProgress(
                  (received / total * 100),
                  speed,
                );
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
          )
          .catchError((onError) {})
          .whenComplete(() {});
      // debugPrint(response.statusMessage);
    } on DioError catch (e) {
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
          'randomDataString': getRandomString(15000000),
        },
        onSendProgress: (int received, int total) {
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
    }
  }

  Future<void> getResponseTime({
    required String url,
    required ProgressResponseCallback onProgress,
  }) async {
    List<int> pingResult = [];
    for (var i = 0; i < 10; i++) {
      var ping = await testResponse(url);

      pingResult.add(ping);
    }

    // int sum = pingResult.fold(0, (p, c) => p + c);

    var responseTime = pingResult.reduce(min);

    /// calculate jitter
    ///
    int jitter = _calculateJitter(pingResult);

    onProgress(responseTime, jitter);
  }

  int _calculateJitter(List<int> pingResult) {
    final jitter = <int>[];
    for (var i = 0; i < pingResult.length; i++) {
      if (i > 0) {
        if (i < pingResult.length - 1) {
          if (pingResult[i] < pingResult[i + 1]) {
            jitter.add((pingResult[i] + 1) - pingResult[i]);
          } else {
            jitter.add(pingResult[i] - (pingResult[i + 1]));
          }
        } else {}
      }
    }

    int sumJitter = jitter.fold(0, (p, c) => p + c);

    var resultJitter = sumJitter ~/ (jitter.length - 1);
    return resultJitter;
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

      return duration;
    } catch (e) {
      return 0;
    }
  }
}

class SpeedtestEvent {}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
