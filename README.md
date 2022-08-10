
# flutter_speedtest

Check your Internet speed test.




## Getting started

### Add dependency

```yaml
dependencies:
  flutter_speedtest: ^0.0.2+2
```


## Usage


```dart

import 'package:flutter_speedtest/flutter_speedtest.dart';

  final _speedtest = FlutterSpeedtest(
    baseUrl: 'http://speedtest.jaosing.com:8080', // your server url
    pathDownload: '/download', 
    pathUpload: '/upload',
    pathResponseTime: '/ping',
  );


  _speedtest.getDataspeedtest(
    downloadOnProgress: ((percent, transferRate) {
      //TODO: in ui
    }),
    uploadOnProgress: ((percent, transferRate) {
     //TODO: in ui
    }),
    progressResponse: ((responseTime, jitter) {
      //TODO: in ui
    }),
    onError: ((errorMessage) {
      //TODO: in ui
    }),
  );


```

## Inspiration

* [internet_speed_test](https://github.com/TahaMalas/internet_speed_test).
* [speedtest-android](https://github.com/librespeed/speedtest-android) for Android.