import 'package:flutter/material.dart';
import 'package:flutter_ve_sdk/audio_browser.dart';
import 'package:flutter_ve_sdk/src/my_app.dart';
// import 'package:url_launcher/url_launcher_string.dart';

void main() {
  runApp(MyApp());
}

/// The entry point for Audio Browser implementation
@pragma('vm:entry-point')
void audioBrowser() => runApp(AudioBrowserWidget());
