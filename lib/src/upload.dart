import 'dart:async';
// import 'dart:convert';
// import 'dart:math' as math;
import 'dart:typed_data';
// import 'dart:typed_data';

import 'package:dio/dio.dart' hide ProgressCallback;
// import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../flutter_speedtest.dart';

class Upload {
  Upload();

  final _dio = Dio();
  final _uuid = const Uuid();

  CancelToken cancelToken = CancelToken();

  late Timer s;
  var dlCalled = false;
  var testState =
      -1; // -1=not started, 0=starting, 1=download test, 2=ping+jitter test, 3=upload test, 4=finished, 5=abort
  var dlStatus = ""; // download speed in megabit/s with 2 decimal digits
  var ulStatus = ""; // upload speed in megabit/s with 2 decimal digits
  var pingStatus = ""; // ping in milliseconds with 2 decimal digits
  var jitterStatus = ""; // jitter in milliseconds with 2 decimal digits
  var clientIp = ""; // client's IP address as reported by getIP.php
  double dlProgress = 0; // progress of download test 0-1
  double ulProgress = 0; // progress of upload test 0-1
  var pingProgress = 0; // progress of ping+jitter test 0-1

  Future<void> uploadProgress({
    required String url,
    required ProgressCallback onProgress,
    required ErrorCallback onError,
    required OnDone onDone,
  }) async {
    try {
      const int totalBytes = 100 * 1024 * 1024; // Total bytes to send (100MB)
      const int chunkSize =
          25 * 1024 * 1024; // Chunk size for each request (25MB)
      final String nocache = _uuid.v4();
      final String guid = _uuid.v4();
      int sentBytes = 0;

      final Stopwatch stopwatch = Stopwatch()..start();

      final futures = <Future>[];

      for (int i = 0; i < 4; i++) {
        final int remainingBytes = totalBytes - sentBytes;
        final int bytesToSend =
            chunkSize < remainingBytes ? chunkSize : remainingBytes;
        final Uint8List chunk = Uint8List(bytesToSend);
        sentBytes += bytesToSend;

        final future = _dio.post(
          url,
          data: FormData.fromMap({
            'chunk': MultipartFile.fromBytes(
              chunk,
              filename: 'chunk.bin',
            ),
          }),
          queryParameters: {
            'nocache': nocache,
            'guid': guid,
          },
          onSendProgress: (int sent, int total) {
            final double seconds = stopwatch.elapsedMilliseconds / 1000;
            final double speedMbps = (sentBytes * 8 / 1000000) / seconds;
            onProgress(sentBytes / totalBytes, speedMbps);

            if (seconds >= 15) {
              // Test is over, stop the upload
              onDone();
            }
          },
          options: Options(
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            },
            headers: {
              'Content-Length': bytesToSend.toString(),
              'Content-Type': 'application/octet-stream',
            },
          ),
        );

        futures.add(future);
      }

      await Future.wait(futures); // Tunggu hingga semua permintaan selesai

      onDone();
    } on DioError catch (e) {
      onError(e.error.toString());
    }
  }

  // Future<void> uploadProgress({
  //   required String url,
  //   required ProgressCallback onProgress,
  //   required ErrorCallback onError,
  //   required OnDone onDone,
  // }) async {
  //   try {
  //     final Stopwatch stopwatch = Stopwatch()..start();
  //     const int totalBytes = 25 * 1024 * 1024; // Total bytes to send (25MB)
  //     int sentBytes = 0;

  //     const int chunkSize = 25 * 1024 * 1024; // Chunk size for streaming (25MB)

  //     final String nocache = _uuid.v4();
  //     final String guid = _uuid.v4();

  //     for (int i = 0; i < 4; i++) {
  //       // Ubah ini menjadi 1 request saja
  //       final chunk = Uint8List(chunkSize);
  //       sentBytes += chunkSize;

  //       final response = await _dio.post(
  //         url,
  //         data: FormData.fromMap({
  //           'chunk': MultipartFile.fromBytes(
  //             chunk,
  //             filename: 'chunk.bin',
  //           ),
  //         }),
  //         queryParameters: {
  //           'nocache': nocache,
  //           'guid': guid,
  //         },
  //         onSendProgress: (int sent, int total) {
  //           final double seconds = stopwatch.elapsedMilliseconds / 1000;
  //           final double speedMbps = (sentBytes * 8 / 1000000) / seconds;
  //           onProgress(sentBytes / totalBytes, speedMbps);

  //           if (seconds >= 15) {
  //             // Test is over, stop the upload
  //             s.cancel();
  //             onDone();
  //           }
  //         },
  //         options: Options(
  //           followRedirects: false,
  //           validateStatus: (status) {
  //             return status! < 500;
  //           },
  //           headers: {
  //             'Content-Length': chunkSize.toString(),
  //             'Content-Type': 'application/octet-stream',
  //           },
  //         ),
  //       );

  //       if (response.statusCode != 200) {
  //         throw DioError(
  //           requestOptions: response.requestOptions,
  //           error: 'HTTP Error ${response.statusCode}',
  //         );
  //       }
  //     }

  //     onDone();
  //   } on DioError catch (e) {
  //     onError(e.error.toString());
  //   }
  // }

  // Future<v
}
