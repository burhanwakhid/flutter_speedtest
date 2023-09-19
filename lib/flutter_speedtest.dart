library flutter_speedtest;

import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_speedtest/src/download.dart';
import 'package:flutter_speedtest/src/response_time.dart';
import 'package:flutter_speedtest/src/upload.dart';

typedef DoneCallback = void Function(double transferRate);

typedef IsDoneCallback = void Function(bool isDone);

typedef ProgressCallback = void Function(
  double percent,
  double transferRate,
);
typedef ProgressResponseCallback = void Function(
  int responseTime,
  int jitter,
);

typedef ErrorCallback = void Function(String errorMessage);
typedef OnDone = void Function();

final _dio = Dio();

/// [FlutterSpeedtest] is a singleton class that provides assess to Speedtest events
class FlutterSpeedtest {
  FlutterSpeedtest({
    required this.baseUrl,
    required this.pathDownload,
    required this.pathUpload,
    required this.pathResponseTime,
  });

  final String baseUrl;
  final String pathDownload;
  final String pathUpload;
  final String pathResponseTime;

  final _download = Download();
  final _upload = Upload();
  final _responseTime = ResponseTime(_dio);

  /// method download is a method that provides assess to download speed
  Future<void> getDataspeedtest({
    required ProgressCallback downloadOnProgress,
    required ProgressCallback uploadOnProgress,
    required ProgressResponseCallback progressResponse,
    required ErrorCallback onError,
    required OnDone onDone,
  }) async {
    try {
      // get response time
      await _responseTime.getResponseTime(
        url: baseUrl + pathResponseTime,
        onProgress: progressResponse,
      );

      // get download speed
      _download.dlTest(
        url: baseUrl + pathDownload,
        onProgress: downloadOnProgress,
        onError: onError,
        isDone: (isDone) async {
          if (isDone) {
            // print('sdfdsfdfsds');
            // get upload speed
            // _upload.uploadProgress(
            //   url: baseUrl + pathUpload,
            //   onProgress: uploadOnProgress,
            //   onError: onError,
            //   onDone: onDone,
            // );
            _upload.uploadProgress(
              url: baseUrl + pathUpload,
              onProgress: uploadOnProgress,
              onError: onError,
              onDone: onDone,
            );
          }
        },
      );

      // get upload speed
      // await _upload.ulTest(
      //   url: baseUrl + pathUpload,
      //   onProgress: uploadOnProgress,
      //   onError: onError,
      // );
    } catch (e) {
      onError(e.toString());
    }
  }
}

class SpeedtestEvent {}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) {
  var str = String.fromCharCodes(
    Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))),
  );

  return str;
}
