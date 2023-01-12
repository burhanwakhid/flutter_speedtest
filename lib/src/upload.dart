import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart' hide ProgressCallback;
import 'package:flutter/foundation.dart';
import 'package:flutter_speedtest/flutter_speedtest.dart';
import 'package:flutter_speedtest/src/settings/settings.dart';
import 'package:uuid/uuid.dart';

typedef OnUploadProgressCallback = void Function(int sentBytes, int totalBytes);

class Upload {
  Upload();

  final _dio = Dio();
  final _uuid = const Uuid();

  CancelToken cancelToken = CancelToken();

  static bool trustSelfSigned = true;

  static HttpClient getHttpClient() {
    HttpClient httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10)
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);

    return httpClient;
  }

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

  Future<void> uploadProgress({
    required String url,
    // Function(double)? onProgress,
    required ProgressCallback onProgress,
    required ErrorCallback onError,
    required OnDone onDone,
  }) async {
    try {
      print('s');
      final sendDate = DateTime.now();

      final postData = await compute(getRandomString, 1500000);
      // double speeds = 0;

      await _dio.post(
        url,
        data: {
          'randomDataString': postData,
        },
        onSendProgress: (int received, int total) {
          if (total != -1) {
            int t = DateTime.now().millisecondsSinceEpoch -
                sendDate.millisecondsSinceEpoch;

            double bonusT = 0;

            int totUploaded = 0;
            totUploaded += received;

            double speed = totUploaded / ((t < 100 ? 100 : t) / 1000.0);

            double bonus = (5.0 * speed) / 100000;
            bonusT += bonus > 400 ? 400 : bonus;

            double progress = (t + bonusT) / (14 * 1000).toDouble();
            speed = (speed * 8 * 1.06) / 1000000.0;

            if ((t + bonusT) / 100000.0 > 15) {
              // test is over, stop streams and timer
              debugPrint('upload test over');
              // cancelToken.cancel();
              s.cancel();
              onDone();
            }

            onProgress(
              progress,
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

      onDone();

      // print(response.headers);
    } on DioError catch (e) {
      onError(e.error.toString());
    }
  }

  Future<void> ulTest({
    required String url,
    required ProgressCallback onProgress,
    required ErrorCallback onError,
    required OnDone onDone,
  }) async {
    // const ulCkSize = 20;
    // final garbage = Uint8List(ulCkSize * 1048576);
    var _random = math.Random();
    // dart array buffer
    var r = Uint8List.fromList([1048576]);

    var maxInt = math.pow(2, 32) - 1;

    // uint8list to uint32list
    // var uint32list = Uint32List.view(r.buffer);
    r = Uint8List.view(r.buffer);
    for (var i = 0; i < r.length; i++) {
      r[i] = _random.nextInt(100) * maxInt.toInt();
    }

    var req = <Uint8List>[];
    var reqsmall = <Uint8List>[];
    for (var i = 0; i < SpeedtestSetting.xhrulblobmegabytes; i++) {
      req.add(r);
    }
    // req = Blob
    r = Uint8List.fromList([262144]);

    r = Uint8List.fromList(r);
    for (var i = 0; i < r.length; i++) {
      r[i] = _random.nextInt(100) * maxInt.toInt();
    }

    reqsmall.add(r);

    // ignore: prefer_function_declarations_over_variables
    var testFunction = () {
      var totLoaded = 0.0, // total number of transmitted bytes
          startT = DateTime.now()
              .millisecondsSinceEpoch, // timestamp when test was started

          graceTimeDone = false, //set to true after the grace time is past
          failed = false; // set to true if a stream fails
      double bonusT =
          0; //how many milliseconds the test has been shortened by (higher on faster connections)

      // ignore: prefer_function_declarations_over_variables
      var testStream = (
        int i,
        int delay,
      ) {
        return Timer(
          Duration(milliseconds: 1 + delay),
          () async {
            var prevLoaded =
                0; // number of bytes transmitted last time onprogress was called
            bool ie11workaround;
            if (SpeedtestSetting.forceIE11Workaround) {
              ie11workaround = true;
            } else {
              try {
                ie11workaround = false;
              } catch (e) {
                ie11workaround = true;
              }
            }

            if (ie11workaround) {
              await _dio.post(
                url +
                    urlSep(url) +
                    'cors=true&' +
                    "r=" +
                    random(1, 1000).toString(),

                // cancelToken: cancelToken,
                onReceiveProgress: (int received, int total) {
                  totLoaded += 16384;
                },
                // cancelToken: cancelToken1,
                //Received data with List<int>
                options: Options(
                  headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'Content-Length': 16384,
                  },
                  responseType: ResponseType.bytes,
                  followRedirects: false,
                  validateStatus: (status) {
                    return status! < 500;
                  },
                ),
              );
            } else {
              String postData = '';
              const List<String> _jsScripts = <String>['getrandomstring.js'];

              /// our `get` function on the `fetch_function.js` file
              const String _jsGetFunctionName = 'randomstring';
              // if (kIsWeb) {
              //   await JsIsolatedWorker().importScripts(_jsScripts);

              //   postData = await JsIsolatedWorker().run(
              //     functionName: _jsGetFunctionName,
              //     arguments: 20000000,
              //   ) as String;
              // } else {
              //   print('object');
              // postData = await compute(getRandomString, 20000000);
              postData = getRandomString(20000000);
              // }
              print(
                url + urlSep(url) + 'nocache=${_uuid.v4()}&guid=${_uuid.v4()}',
              );
              // var postData = await compute(getRandomString, 15000000);
              FormData formData = FormData.fromMap({
                'image': postData,
              });
              print(
                url + urlSep(url) + 'nocache=${_uuid.v4()}&guid=${_uuid.v4()}',
              );
              await _dio.post(
                url + urlSep(url) + 'nocache=${_uuid.v4()}&guid=${_uuid.v4()}',
                data: formData,
                onSendProgress: (int received, int total) {
                  if (total != -1) {
                    var loadDiff = received <= 0 ? 0 : received - prevLoaded;
                    if (loadDiff.isNaN || !loadDiff.isFinite || loadDiff < 0) {
                      return;
                    } // just in case
                    totLoaded += loadDiff;
                    prevLoaded = received;
                  }
                },
                //Received data with List<int>
                options: Options(
                  headers: {
                    'Content-Encoding': 'identity',
                    // 'Content-Type': 'application/octet-stream',
                    // 'Connection': 'keep-alive',
                    // Headers.contentLengthHeader:
                    //     utf8.encode(jsonEncode(body)).length,
                  },
                  followRedirects: false,
                  validateStatus: (status) {
                    return status! < 500;
                  },
                ),
              );
            }
          },
        );
      };

      // open streams
      for (var i = 0; i < SpeedtestSetting.xhrUlMultistream; i++) {
        testStream(i, SpeedtestSetting.xhrUlMultistream * i);
      }

      // every 200ms, update ulStatus
      s = Timer.periodic(
        const Duration(milliseconds: 300),
        (timer) {
          var t = DateTime.now().millisecondsSinceEpoch - startT;
          if (graceTimeDone) {
            ulProgress = (t + bonusT) / (SpeedtestSetting.timeUlMax * 1000);
          }
          if (t < 200) return;
          if (!graceTimeDone) {
            // print('object');
            // print(t);
            // print(1000 * SpeedtestSetting.timeUlGraceTime);
            if (t >= 1000 * SpeedtestSetting.timeUlGraceTime) {
              print('agaga');
              if (totLoaded > 0) {
                print('adf');
                // if the connection is so slow that we didn't get a single chunk yet, do not reset
                startT = DateTime.now().millisecondsSinceEpoch;
                bonusT = 0;
                totLoaded = 0.0;
              }
              graceTimeDone = true;
            }
          } else {
            var speed = totLoaded / ((t < 100 ? 100 : t) / 1000.0);
            if (SpeedtestSetting.timeAuto) {
              //decide how much to shorten the test. Every 200ms, the test is shortened by the bonusT calculated here
              double bonus = (5.0 * speed) / 100000;
              bonusT += bonus > 400 ? 400 : bonus;
            }

            // setState(() {
            //update status
            var progress = (t + bonusT) / (14 * 1000).toDouble();

            ulStatus = ((speed *
                        8 *
                        SpeedtestSetting.overheadCompensationFactor) /
                    (SpeedtestSetting.useMebibits ? 1048576 : 1000000))
                .toStringAsFixed(
                    2); // speed is multiplied by 8 to go from bytes to bits, overhead compensation is applied, then everything is divided by 1048576 or 1000000 to go to megabits/mebibits
            var uploadRate =
                ((speed * 8 * SpeedtestSetting.overheadCompensationFactor) /
                    (SpeedtestSetting.useMebibits ? 1048576 : 1000000));
            // print(uploadRate);
            // showRate =
            //     ((speed * 8 * SpeedtestSetting.overheadCompensationFactor) /
            //         (SpeedtestSetting.useMebibits ? 1048576 : 1000000));
            onProgress(
              progress,
              uploadRate,
            );
            // });
            if ((t + bonusT) / 1000.0 > SpeedtestSetting.timeUlMax || failed) {
              // test is over, stop streams and timer
              if (failed || ulStatus.isEmpty) ulStatus = "Fail";
              // cancelToken.cancel();
              s.cancel();
              onDone();
            }
          }
        },
      );
    };

    testFunction();
  }
}
