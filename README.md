
# flutter_speedtest

Check your Internet speed test.




## Getting started

### Add dependency

```yaml
dependencies:
  flutter_speedtest: ^0.0.1
```


## Usage


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