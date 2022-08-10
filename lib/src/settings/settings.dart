import 'dart:math';

class SpeedtestSetting {
  static bool mpot = false;
  static String testOrder = 'IP_D_U';
  static int timeUlMax = 15;
  static int timeDlMax = 15;
  static bool timeAuto = true;

  // mpot: false, //set to true when in MPOT mode
  // test_order: "IP_D_U", //order in which tests will be performed as a string. D=Download, U=Upload, P=Ping+Jitter, I=IP, _=1 second delay
  // time_ul_max: 15, // max duration of upload test in seconds
  // time_dl_max: 15, // max duration of download test in seconds
  // time_auto: true, // if set to true, tests will take less time on faster connections
  static int timeUlGraceTime =
      3; //time to wait in seconds before actually measuring ul speed (wait for buffers to fill)
  static double timeDlGraceTime =
      1.5; // time_dlGraceTime: 1.5, //time to wait in seconds before actually measuring dl speed (wait for TCP window to increase)
  static int countPing =
      10; // count_ping: 10, // number of pings to perform in ping test
  static String urlDl =
      'backend/garbage.php'; // url_dl: "backend/garbage.php", // path to a large file or garbage.php, used for download test. must be relative to this js file
  static String urlUl =
      'backend/empty.php'; // url_ul: "backend/empty.php", // path to an empty file, used for upload test. must be relative to this js file
  static String urlPing =
      'backend/empty.php'; // url_ping: "backend/empty.php", // path to an empty file, used for ping test. must be relative to this js file
  static String urlGetIp =
      'backend/getIP.php'; // url_getIp: "backend/getIP.php", // path to getIP.php relative to this js file, or a similar thing that outputs the client's ip
  // getIp_ispInfo: true, //if set to true, the server will include ISP info with the IP address
  // getIp_ispInfo_distance: "km", //km or mi=estimate distance from server in km/mi; set to false to disable distance estimation. getIp_ispInfo must be enabled in order for this to work
  static int xhrDlMultistream =
      4; // xhr_dlMultistream: 6, // number of download streams to use (can be different if enable_quirks is active)
  static int xhrUlMultistream =
      3; // xhr_ulMultistream: 3, // number of upload streams to use (can be different if enable_quirks is active)
  static int xhrMultistreamDelay =
      300; // xhr_multistreamDelay: 300, //how much concurrent requests should be delayed
  static int xhrIgnoreErrors =
      1; // xhr_ignoreErrors: 1, // 0=fail on errors, 1=attempt to restart a stream if it fails, 2=ignore all errors
  static bool xhrDlUseBlob =
      false; // xhr_dlUseBlob: false, // if set to true, it reduces ram usage but uses the hard drive (useful with large garbagePhp_chunkSize and/or high xhr_dlMultistream)
  static int xhrulblobmegabytes =
      20; // xhr_ul_blob_megabytes: 20, //size in megabytes of the upload blobs sent in the upload test (forced to 4 on chrome mobile)
  static int garbagePhpchunkSize =
      100; // garbagePhp_chunkSize: 100, // size of chunks sent by garbage.php (can be different if enable_quirks is active)
  static bool enableQuirks =
      true; // enable_quirks: true, // enable quirks for specific browsers. currently it overrides settings to optimize for specific browsers, unless they are already being overridden with the start command
  static bool pingallowPerformanceApi =
      true; // ping_allowPerformanceApi: true, // if enabled, the ping test will attempt to calculate the ping more precisely using the Performance API. Currently works perfectly in Chrome, badly in Edge, and not at all in Firefox. If Performance API is not supported or the result is obviously wrong, a fallback is provided.
  static double overheadCompensationFactor =
      1.06; // overheadCompensationFactor: 1.06, //can be changed to compensatie for transport overhead. (see doc.md for some other values)
  static bool useMebibits =
      false; // useMebibits: false, //if set to true, speed will be reported in mebibits/s instead of megabits/s
  static int telemetrylevel =
      0; // telemetry_level: 0, // 0=disabled, 1=basic (results only), 2=full (results and timing) 3=debug (results+log)
  static String urltelemetry =
      'results/telemetry.php'; // path to the script that adds telemetry data to the database
  // telemetry_extra: "", //extra data that can be passed to the telemetry through the settings
  static bool forceIE11Workaround =
      false; //   forceIE11Workaround: false //when set to true, it will foce the IE11 upload test on all browsers. Debug only
}

String urlSep(String url) {
  final regExp = RegExp(r'(/\?/)');
  final matches = regExp.hasMatch(url);
  return matches ? "&" : "?";
}

int random(min, max) {
  return min + Random().nextInt(max - min);
}
