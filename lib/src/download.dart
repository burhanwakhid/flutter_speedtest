import 'dart:async';

import 'package:dio/dio.dart' hide ProgressCallback;
import 'package:flutter_speedtest/flutter_speedtest.dart';
import 'package:flutter_speedtest/src/settings/settings.dart';

CancelToken cancelToken = CancelToken();

class Download {
  Download(
    this._dio,
  );

  final Dio _dio;

  // final Upload _upload;

  // CancelToken cancelToken = CancelToken();

  late Timer s;
  var dlCalled = false;
  var testState =
      -1; // -1=not started, 0=starting, 1=download test, 2=ping+jitter test, 3=upload test, 4=finished, 5=abort
  var dlStatus = ""; // download speed in megabit/s with 2 decimal digits
  var ulStatus = ""; // upload speed in megabit/s with 2 decimal digits
  var pingStatus = ""; // ping in milliseconds with 2 decimal digits
  var jitterStatus = ""; // jitter in milliseconds with 2 decimal digits
  var clientIp = ""; // client's IP address as reported by getIP.php
  double dlProgress = 0; //progress of download test 0-1
  double ulProgress = 0; //progress of upload test 0-1
  var pingProgress = 0; //progress of ping+jitter test 0-1

  Future<void> downloadProgress(
      {required String url,
      required ProgressCallback onProgress,
      required ErrorCallback onError,
      required IsDoneCallback isDone,
      required}) async {
    final Dio _dio = Dio();
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

                // double bonusT = 0;

                double speed = totDownloaded / ((t < 100 ? 100 : t) / 1000.0);

                // double b = (2.5 * speed) / 100000.0;
                // bonusT += b > 200 ? 200 : b;

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

  Future<void> dlTest({
    required String url,
    required ProgressCallback onProgress,
    required ErrorCallback onError,
    required IsDoneCallback isDone,
  }) async {
    // add interceptor dio
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        return handler.next(options);
      },
      onResponse: (e, handler) {
        return handler.next(e);
      },
      onError: (e, handler) {
        return handler.resolve(e.response!);
      },
    ));

    isDone(false);
    if (dlCalled) {
      return;
    } else {
      dlCalled = true;
    } // dlTest already called?
    var totLoaded = 0.0, // total number of loaded bytes
        startT = DateTime.now()
            .millisecondsSinceEpoch, // timestamp when test was started

        graceTimeDone = false, //set to true after the grace time is past
        failed = false; // set to true if a stream fails
    double bonusT =
        0; //how many milliseconds the test has been shortened by (higher on faster connections)

    // ignore: prefer_function_declarations_over_variables
    var testStream = (int i, int delay) {
      return Timer(
        Duration(milliseconds: 1 + delay),
        () async {
          // delayed stream ended up starting after the end of the download test
          // if (testState != 1) return;
          var prevLoaded =
              0; // number of bytes loaded last time onprogress was called

          await _dio.get(
            url +
                urlSep(url) +
                'cors=true&' +
                "r=" +
                random(1, 1000).toString() +
                "&ckSize=" +
                SpeedtestSetting.garbagePhpchunkSize.toString(),
            // cancelToken: cancelToken,
            onReceiveProgress: (int received, int total) {
              // if (testState != 1) {
              //   try {
              //     dio.close();
              //   } catch (e) {}
              // } // just in case this XHR is still running after the download test
              // progress event, add number of new loaded bytes to totLoaded
              var loadDiff = received <= 0 ? 0 : received - prevLoaded;
              if (loadDiff.isNaN || !loadDiff.isFinite || loadDiff < 0) {
                return;
              } // just in case
              totLoaded += loadDiff;
              prevLoaded = received;
            },
            //Received data with List<int>
            options: Options(
              headers: {
                "Connection": "Keep-Alive",
                'contentType': 'application/json',
              },
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) {
                return status! < 500;
              },
            ),
          );
        },
      );
    };
    // open streams
    for (var i = 0; i < SpeedtestSetting.xhrDlMultistream; i++) {
      testStream(i, SpeedtestSetting.xhrMultistreamDelay * i);
    }

    // every 200ms, update dlStatus
    s = Timer.periodic(
      const Duration(milliseconds: 200),
      (timer) {
        // print('test');
        var t = DateTime.now().millisecondsSinceEpoch - startT;
        if (graceTimeDone) {
          dlProgress = (t + bonusT) / (SpeedtestSetting.timeDlMax * 1000);
        }
        // print('time: $t');
        // print('time: $t');

        if (t < 200) return;
        if (!graceTimeDone) {
          // print('hehe');
          // print(1000 * SpeedtestSetting.timeDlGraceTime);
          if (t > 1000 * SpeedtestSetting.timeDlGraceTime) {
            // print('hoho');
            if (totLoaded > 0) {
              // if the connection is so slow that we didn't get a single chunk yet, do not reset
              startT = DateTime.now().millisecondsSinceEpoch;
              bonusT = 0;
              totLoaded = 0.0;
            }
            graceTimeDone = true;
          }
        } else {
          var speed = totLoaded / (t / 1000.0);
          if (SpeedtestSetting.timeAuto) {
            //decide how much to shorten the test. Every 200ms, the test is shortened by the bonusT calculated here
            var bonus = (5.0 * speed) / 100000;
            bonusT += bonus > 400 ? 400 : bonus;
          }
          // print('speed: $speed');

          //update status
          dlStatus = ((speed *
                      8 *
                      SpeedtestSetting.overheadCompensationFactor) /
                  (SpeedtestSetting.useMebibits ? 1048576 : 1000000))
              .toStringAsFixed(
                  2); // speed is multiplied by 8 to go from bytes to bits, overhead compensation is applied, then everything is divided by 1048576 or 1000000 to go to megabits/mebibits

          var downloadRate =
              ((speed * 8 * SpeedtestSetting.overheadCompensationFactor) /
                  (SpeedtestSetting.useMebibits ? 1048576 : 1000000));

          onProgress(
            (t + bonusT) / 1000.0,
            downloadRate,
          );

          if ((t + bonusT) / 1000.0 > SpeedtestSetting.timeDlMax || failed) {
            // test is over, stop streams and timer
            if (failed || dlStatus.isEmpty) dlStatus = "Fail";
            // cancelToken.cancel();
            // _dio.close();

            s.cancel();
            isDone(true);
            // _upload.uploadProgress(
            //   url: url,
            //   onProgress: onProgress,
            //   onError: onError,
            // );
            // ulTest('http://speedtest.super.net.sg:8080/upload');
          }
        }
      },
    );
  }
}
