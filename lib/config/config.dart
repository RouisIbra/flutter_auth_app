// API url from the emulator
// The host's OS IP is 10.0.2.2 in Android Emulator

import 'dart:io' show Platform;

final String apiUrl =
    Platform.isAndroid ? "http://10.0.2.2" : "http://localhost:3000";
