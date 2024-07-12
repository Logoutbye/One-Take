// // video_service.dart
// import 'dart:convert';
// import 'dart:io';

// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_ve_sdk/src/config/helpler.dart';
// import 'package:http/http.dart' as http;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:saver_gallery/saver_gallery.dart';

// class VideoService {
//   static const String LICENSE_TOKEN =
//       "Qk5CIPgcrV+G/OnXaR6L4EOqDdtvOE50pEwyM9pC5ImYD3uhJkIWuRk7XnRuzD4GF3ph7B2iq28mMPeXkEfqonPd+kehHL0Gm5C/ttMcK0HhjeT01+2t+R4wOTVUxy8ehTN/M1kF6yRIhzoMIZxl3asu3C52QYrNHYX8l+9FHQnpK98wI3B3izPWUOTWAf2+y8njm6ZZgs/yNRJHpBNJktwgpntFCR9m+Jcq8tjNcewMQhdqfwsRSs98A7qwgaCaY4peQ2RmaUcnbtB2+Fh5rmWPWalvSfk1kND7M6RBwkyLgBKvbDDl0JyEoFynTz2omMf5b4yaNpLPcZNjtxsM46OcAAnec2HKH25U86Kt84d6XgMf9bClKVf1jsOcTxPxXlzy3rIqwHqKXfpG+tCtVQ+XBaSu8GcudWW7owTemDPhyHa0c7U9vTgroKeH3hDAmWj4JIDCo/IzCuzoKjFOGhmxw00vY7uZf2vGqrcNnV2kZwadu9MCFaCKuI4a3332LNoyY6CdutxQKbO+aQ+7VhVHZY79c/fCOhqLOxEWR0n100QpYFyINyNQzHDCN3Zj+5wdMlmf6V2BR3joj2hGeIcOFp849ru4ay5N+1UYFNaH1DLCaQXPH/ulhuHZH/+auCZQFjw0lrYj7+3D+NjlOw==";

//   static const methodInitVideoEditor = 'initVideoEditor';
//   static const methodStartVideoEditorPIP = 'startVideoEditorPIP';
//   static const methodDemoPlayExportedVideo = 'playExportedVideo';
//   static const argExportedVideoFile = 'argExportedVideoFilePath';
//   static const argExportedVideoCoverPreviewPath = 'argExportedVideoCoverPreviewPath';
//   static const platformChannel = MethodChannel('banubaSdkChannel');

//   static Future<void> requestPermission() async {
//     bool statuses;
//     if (Platform.isAndroid) {
//       final deviceInfoPlugin = DeviceInfoPlugin();
//       final deviceInfo = await deviceInfoPlugin.androidInfo;
//       final sdkInt = deviceInfo.version.sdkInt;
//       statuses = sdkInt < 29 ? await Permission.storage.request().isGranted : true;
//     } else {
//       statuses = await Permission.photosAddOnly.request().isGranted;
//     }
//     print(':::: requestPermission result: ${statuses}');
//   }

//   static Future<void> initVideoEditor() async {
//     await platformChannel.invokeMethod(methodInitVideoEditor, LICENSE_TOKEN);
//   }

//   static Future<void> startVideoEditorInPipMode(String videoFilePath) async {
//     await initVideoEditor();

//     try {
//       final result = await platformChannel.invokeMethod(methodStartVideoEditorPIP, videoFilePath);
//       handleVideoEditorResult(result);
//     } on PlatformException catch (e) {
//       handlePlatformException(e);
//     }
//   }

//   static Future<void> saveVideoToGallery(String videoPath) async {
//     final result = await SaverGallery.saveFile(
//         file: videoPath,
//         androidExistNotSave: true,
//         name: '123.mp4',
//         androidRelativePath: "Movies");
//     print(result);
//   }

//   static void handlePlatformException(PlatformException exception) {
//     String errorMessage;
//     switch (exception.code) {
//       case 'ERR_SDK_LICENSE_REVOKED':
//         errorMessage = 'The license is revoked or expired. Please contact Banuba https://www.banuba.com/support';
//         break;
//       case 'ERR_SDK_NOT_INITIALIZED':
//         errorMessage = 'Banuba Video and Photo Editor SDK is not initialized: license token is unknown or incorrect.\nPlease check your license token or contact Banuba';
//         break;
//       case 'ERR_MISSING_EXPORT_RESULT':
//         errorMessage = 'Missing video export result!';
//         break;
//       case 'ERR_START_PIP_MISSING_VIDEO':
//         errorMessage = 'Cannot start video editor in PIP mode: passed video is missing or invalid';
//         break;
//       case 'ERR_START_TRIMMER_MISSING_VIDEO':
//         errorMessage = 'Cannot start video editor in trimmer mode: passed video is missing or invalid';
//         break;
//       case 'ERR_EXPORT_PLAY_MISSING_VIDEO':
//         errorMessage = 'Missing video file to play';
//         break;
//       default:
//         errorMessage = 'unknown error';
//     }
//     print("Error: '${exception.message}'.");
//     print("Error Message: $errorMessage");
//   }

//   static void handleVideoEditorResult(dynamic result) {
//     if (result is Map) {
//       final exportedVideoFilePath = result[argExportedVideoFile];
//       final exportedVideoCoverPreviewPath = result[argExportedVideoCoverPreviewPath];

//       print('Exported video = $exportedVideoFilePath');
//       print('Exported video preview = $exportedVideoCoverPreviewPath');
//     }
//   }

//   static Future<void> fetchInstagramVideo(String videoUrl) async {
//     final url = Uri.parse(
//         'https://instagram-downloader-download-instagram-videos-stories1.p.rapidapi.com/?url=${Uri.encodeComponent(videoUrl)}');
//     final headers = {
//       'x-rapidapi-key': 'f73af0d298mshffd49671f08dbf3p1e74f9jsnfc39709e2678',
//       'x-rapidapi-host': 'instagram-downloader-download-instagram-videos-stories1.p.rapidapi.com',
//     };

//     try {
//       final response = await http.get(url, headers: headers);
//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         if (responseData is List && responseData.isNotEmpty) {
//           final videoData = responseData[0];
//           await downloadFile(videoData['url'], 'video.mp4');
//         }
//       }
//     } catch (e) {
//       print(':::Error downloading video: $e');
//     }
//   }

//   static Future<void> fetchTikTokVideo(String videoUrl) async {
//     const url = "https://tiktok-download-without-watermark.p.rapidapi.com/analysis";

//     try {
//       final response = await http.get(
//         Uri.parse("$url?url=$videoUrl&hd=0"),
//         headers: {
//           "x-rapidapi-key": "652fc95660msh4825c876ba3276bp12a6b1jsnd1d5785bdd60",
//           "x-rapidapi-host": "tiktok-download-without-watermark.p.rapidapi.com",
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final downloadLink = data['data']['play'];
//         await downloadFile(downloadLink, 'video.mp4');
//       } else {
//         print(':::Request failed with status: ${response.statusCode}');
//       }
//     } catch (e) {
//       print(':::Error downloading video: $e');
//     }
//   }

//   static Future<void> downloadFile(String url, String filename) async {
//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       final appPath = await DirHelper.getAppPath();
//       final filePath = '$appPath/$filename';
//       final file = File(filePath);
//       await file.writeAsBytes(response.bodyBytes);
//       await saveVideoToGallery(filePath);
//       startVideoEditorInPipMode(filePath);
//     } else {
//       print('::: Failed to download file');
//     }
//   }
// }
