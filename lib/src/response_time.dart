import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_speedtest/flutter_speedtest.dart';

class ResponseTime {
  ResponseTime(this._dio);

  final Dio _dio;

  Future<void> getResponseTime({
    required String url,
    required ProgressResponseCallback onProgress,
  }) async {
    // final context = SecurityContext.defaultContext;
    // context.allowLegacyUnsafeRenegotiation = true;
    // final httpClient = HttpClient(context: context);
    // final client = Dio()..httpClientAdapter = DefaultHttpClientAdapter(httpClient);
    // _dio.httpClientAdapter = DefaultHttpClientAdapter();
    List<int> pingResult = [];
    for (var i = 0; i < 10; i++) {
      var ping = await _testResponse(url);

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
    return resultJitter == 0 ? 1 : resultJitter;
  }

  Future<int> _testResponse(String url) async {
    try {
      final sendDate = DateTime.now();

      await _dio.head(
        url,
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
