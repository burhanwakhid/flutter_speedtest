<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

# flutter_speedtest

Check your Internet speed test.


<!-- ## Features

TODO: List what your package can do. Maybe include images, gifs, or videos. -->

## Getting started

### Add dependency

```yaml
dependencies:
  flutter_speedtest: ^0.0.1
```


## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder. 

```dart

import 'package:flutter_speedtest/flutter_speedtest.dart';

 final _speedtest = FlutterSpeedtest();

_speedtest.downloadProgress(
  url:
      'http://speedtest-sby.natanetwork.co.id:8080/speedtest/download?size=25000000',
  onProgress: (percent, transferRate) {
    // TODO: Change UI
  },
  onError: (errorMessage) {},
);


_speedtest.uploadProgress(
  url:
      'http://speedtest-sby.natanetwork.co.id:8080/speedtest/upload.php',
  onProgress: (percent, transferRate) {
    // TODO: Change UI
  },
  onError: (errorMessage) {},
);

_speedtest.getResponseTime(
  url:
      'http://speedtest-sby.natanetwork.co.id:8080/speedtest/ping',
  onProgress: (responseTime, jitter) {
    // TODO: Change UI
  },
);


```

## Inspiration

* [internet_speed_test](https://github.com/TahaMalas/internet_speed_test).
* [speedtest-android](https://github.com/librespeed/speedtest-android) for Android.