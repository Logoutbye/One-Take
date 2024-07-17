import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ve_sdk/src/config/helpler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_ve_sdk/src/core/widgets/center_indicator.dart';
import 'package:flutter_ve_sdk/src/core/widgets/custom_elevated_btn.dart';
import 'package:flutter_ve_sdk/src/features/banuba_duet/widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent_plus/receive_sharing_intent_plus.dart';
import 'package:saver_gallery/saver_gallery.dart';

// kkk
class HomeDuet extends StatefulWidget {
  const HomeDuet({super.key});

  @override
  State<HomeDuet> createState() => _HomeDuetState();
}

class _HomeDuetState extends State<HomeDuet> {

  
  SharedMediaFile? _sharedFile;
  String? _sharedUrl;

  late StreamSubscription _intentMediaStreamSubscription;
  late StreamSubscription _intentTextStreamSubscription;

  @override
  void initState() {
    super.initState();
    handleSharedContent();
    _requestPermission();
  }

  Future<void> handleSharedContent() async {
    // Handle shared media files while the app is in the foreground
    ReceiveSharingIntentPlus.getMediaStream().listen(
      (List<SharedMediaFile> value) {
        if (value.isNotEmpty) {
          SharedMediaFile sharedFile = value.first;
          debugPrint(':::Shared File: ${sharedFile.path}');
          // _detectAndPrintMediaType(sharedFile.type);
          // if (sharedFile.type == 'Video') {
          //  VideoService.startVideoEditorInPipMode(sharedFile.path, context);
          _startVideoEditorInPipModeForInsta(sharedFile.path);
          // }
        }
      },
      onError: (err) {
        debugPrint('::: getMediaStream error: $err');
      },
    );

    // Handle shared media files while the app is closed
    List<SharedMediaFile> initialMedia =
        await ReceiveSharingIntentPlus.getInitialMedia();
    if (initialMedia.isNotEmpty) {
      SharedMediaFile sharedFile = initialMedia.first;
      debugPrint(':::Shared File (initial): ${sharedFile.path}');
      // _detectAndPrintMediaType(sharedFile.type);

      // if (sharedFile.type == 'Video') {
      _startVideoEditorInPipModeForInsta(sharedFile.path);
      // }
    }

    // Handle shared URLs/text while the app is in the foreground
    ReceiveSharingIntentPlus.getTextStream().listen(
      (String value) {
        if (value.isNotEmpty) {
          debugPrint(':::Shared URL/Text: $value');
          _detectAndPrintUrlType(value);
        }
      },
      onError: (err) {
        debugPrint(':::getTextStream error: $err');
      },
    );

    // Handle shared URLs/text while the app is closed
    String? initialText = await ReceiveSharingIntentPlus.getInitialText();
    if (initialText != null && initialText.isNotEmpty) {
      debugPrint(':::Shared URL/Text (initial): $initialText');
      _detectAndPrintUrlType(initialText);
    }
  }

  // Private function to detect and print the source of the shared URL
  void _detectAndPrintUrlType(String url) {
    genericVideoLinkController = TextEditingController(text: url);
    if (url.contains('tiktok')) {
      _showDownloadBottomSheet(context, 'tiktok');
      debugPrint(':::Shared URL Type: TikTok');
    } else if (url.contains('instagram')) {
      _showDownloadBottomSheet(context, 'instagram');

      debugPrint(':::Shared URL Type: Instagram');
    } else {
      debugPrint(':::Shared URL Type: Storage');
    }
  }

  _requestPermission() async {
    bool statuses;
    if (Platform.isAndroid) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final deviceInfo = await deviceInfoPlugin.androidInfo;
      final sdkInt = deviceInfo.version.sdkInt;
      statuses =
          sdkInt < 29 ? await Permission.storage.request().isGranted : true;
      // statuses = await Permission.storage.request().isGranted;
    } else {
      statuses = await Permission.photosAddOnly.request().isGranted;
    }
    print(':::: requestPermission result: ${statuses}');
  }

  TextEditingController genericVideoLinkController = TextEditingController();
  bool _downloading = false;
  bool _downloadingtiktok = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("One Take"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 100,
                height: 100,
                child: Icon(
                  Icons.storage,
                  size: 52,
                ),
              ),
              const SizedBox(height: 24),
              MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                disabledColor: Colors.grey,
                disabledTextColor: Colors.black,
                padding: const EdgeInsets.all(12.0),
                splashColor: Colors.blueAccent,
                minWidth: 240,
                onPressed: () async {
                  _startVideoEditorInPipMode();
                },
                child: const Text(
                  'Duet From Local Storage',
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ),
              Divider(),
              const InstaLogo(),
              const SizedBox(height: 24),
              _downloading
                  ? const CenterProgressIndicator()
                  : MaterialButton(
                      color: Colors.blue,
                      textColor: Colors.white,
                      disabledColor: Colors.grey,
                      disabledTextColor: Colors.black,
                      padding: const EdgeInsets.all(12.0),
                      splashColor: Colors.blueAccent,
                      minWidth: 240,
                      onPressed: () {
                        _showDownloadBottomSheet(context, "instagram");
                      },
                      child: const Text(
                        'Duet from Instagram ',
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ),
              Divider(),
              const DownloaderBodyLogo(),
              const SizedBox(height: 24),
              _downloadingtiktok
                  ? const CenterProgressIndicator()
                  : Column(children: [
                      MaterialButton(
                        color: Colors.blue,
                        textColor: Colors.white,
                        disabledColor: Colors.grey,
                        disabledTextColor: Colors.black,
                        padding: const EdgeInsets.all(12.0),
                        splashColor: Colors.blueAccent,
                        minWidth: 240,
                        onPressed: () {
                          _showDownloadBottomSheet(context, "tiktok");
                        },
                        child: const Text(
                          'Duet from Tiktok ',
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ])
            ],
          ),
        ),
      ),
    );
  }

  // Set Banuba license token for Video and Photo Editor SDK
  static const String LICENSE_TOKEN =
      "Qk5CIPgcrV+G/OnXaR6L4EOqDdtvOE50pEwyM9pC5ImYD3uhJkIWuRk7XnRuzD4GF3ph7B2iq28mMPeXkEfqonPd+kehHL0Gm5C/ttMcK0HhjeT01+2t+R4wOTVUxy8ehTN/M1kF6yRIhzoMIZxl3asu3C52QYrNHYX8l+9FHQnpK98wI3B3izPWUOTWAf2+y8njm6ZZgs/yNRJHpBNJktwgpntFCR9m+Jcq8tjNcewMQhdqfwsRSs98A7qwgaCaY4peQ2RmaUcnbtB2+Fh5rmWPWalvSfk1kND7M6RBwkyLgBKvbDDl0JyEoFynTz2omMf5b4yaNpLPcZNjtxsM46OcAAnec2HKH25U86Kt84d6XgMf9bClKVf1jsOcTxPxXlzy3rIqwHqKXfpG+tCtVQ+XBaSu8GcudWW7owTemDPhyHa0c7U9vTgroKeH3hDAmWj4JIDCo/IzCuzoKjFOGhmxw00vY7uZf2vGqrcNnV2kZwadu9MCFaCKuI4a3332LNoyY6CdutxQKbO+aQ+7VhVHZY79c/fCOhqLOxEWR0n100QpYFyINyNQzHDCN3Zj+5wdMlmf6V2BR3joj2hGeIcOFp849ru4ay5N+1UYFNaH1DLCaQXPH/ulhuHZH/+auCZQFjw0lrYj7+3D+NjlOw==";

  // For Video Editor
  static const methodInitVideoEditor = 'initVideoEditor';
  static const methodStartVideoEditorPIP = 'startVideoEditorPIP';
  static const methodDemoPlayExportedVideo = 'playExportedVideo';
  static const argExportedVideoFile = 'argExportedVideoFilePath';
  static const argExportedVideoCoverPreviewPath = 'argExportedVideoCoverPreviewPath';
  static const platformChannel = MethodChannel('banubaSdkChannel');

  String errorMessage = '';

  Future<void> _initVideoEditor() async {
    await platformChannel.invokeMethod(methodInitVideoEditor, LICENSE_TOKEN);
  }

  Future<void> _startVideoEditorInPipMode() async {
    try {
      await _initVideoEditor();

      // Use your implementation to provide correct video file path to start Video Editor SDK in PIP mode
      final ImagePicker _picker = ImagePicker();
      final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);

      if (file == null) {
        debugPrint(
            'Cannot open video editor with PIP - video was not selected!');
      } else {
        debugPrint('Open video editor in pip with video = ${file.path}');
        final result = await platformChannel.invokeMethod(
            methodStartVideoEditorPIP, file.path);

        _handleVideoEditorResult(result);
      }
    } on PlatformException catch (e) {
      _handlePlatformException(e);
    }
  }

  // Handle exceptions thrown on Android, iOS platform while starting Video and Photo Editor SDK
  void _handlePlatformException(PlatformException exception) {
    debugPrint("Error: '${exception.message}'.");

    String errorMessage = '';
    switch (exception.code) {
      case 'ERR_SDK_LICENSE_REVOKED':
        errorMessage =
            'The license is revoked or expired. Please contact Banuba https://www.banuba.com/support';
        break;
      case 'ERR_SDK_NOT_INITIALIZED':
        errorMessage =
            'Banuba Video and Photo Editor SDK is not initialized: license token is unknown or incorrect.\nPlease check your license token or contact Banuba';
        break;
      case 'ERR_MISSING_EXPORT_RESULT':
        errorMessage = 'Missing video export result!';
        break;
      case 'ERR_START_PIP_MISSING_VIDEO':
        errorMessage =
            'Cannot start video editor in PIP mode: passed video is missing or invalid';
        break;
      case 'ERR_START_TRIMMER_MISSING_VIDEO':
        errorMessage =
            'Cannot start video editor in trimmer mode: passed video is missing or invalid';
        break;
      case 'ERR_EXPORT_PLAY_MISSING_VIDEO':
        errorMessage = 'Missing video file to play';
        break;
      default:
        errorMessage = 'unknown error';
    }

    errorMessage = errorMessage;
    setState(() {});
  }

  void _handleVideoEditorResult(dynamic result) {
    debugPrint('Received Video Editor result');

    // You can use any kind of export result passed from platform.
    // Map is used for this sample to demonstrate playing exported video file.
    if (result is Map) {
      final exportedVideoFilePath = result[argExportedVideoFile];

      debugPrint('Exported video = $exportedVideoFilePath');

      // Use video cover preview to meet your requirements
      final exportedVideoCoverPreviewPath =
          result[argExportedVideoCoverPreviewPath];

      debugPrint('Exported video preview = $exportedVideoCoverPreviewPath');

      _showConfirmation(context, "Play exported video file?", () {
        platformChannel.invokeMethod(
            methodDemoPlayExportedVideo, exportedVideoFilePath);
      });

      saveVideoToGallery(exportedVideoFilePath);
    }
  }

  void _showConfirmation(
      BuildContext context, String message, VoidCallback block) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
        actions: [
          MaterialButton(
            color: Colors.red,
            textColor: Colors.white,
            disabledColor: Colors.grey,
            disabledTextColor: Colors.black,
            padding: const EdgeInsets.all(12.0),
            splashColor: Colors.redAccent,
            onPressed: () => {Navigator.pop(context)},
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          ),
          MaterialButton(
            color: Colors.green,
            textColor: Colors.white,
            disabledColor: Colors.grey,
            disabledTextColor: Colors.black,
            padding: const EdgeInsets.all(12.0),
            splashColor: Colors.greenAccent,
            onPressed: () {
              Navigator.pop(context);
              block.call();
            },
            child: const Text(
              'Ok',
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _startVideoEditorInPipModeForInsta(var sourceVideoFile) async {
    await _initVideoEditor();

    if (sourceVideoFile == null) {
      debugPrint(
          'Error: Cannot start video editor in pip mode: please pick video file');
      return;
    }

    try {
      final result = await platformChannel.invokeMethod(
          methodStartVideoEditorPIP, sourceVideoFile);

      _handleVideoEditorResult(result);
    } on PlatformException catch (e) {
      _handlePlatformException(e);
    }
  }

  void _showDownloadBottomSheet(BuildContext context, String platform) {
    showModalBottomSheet(
      isScrollControlled:
          true, // This makes the bottom sheet full-screen when keyboard is shown
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                platform == "tiktok" ? DownloaderBodyLogo() : InstaLogo(),
                SizedBox(height: 20),
                TextField(
                  controller: genericVideoLinkController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: platform == "tiktok"
                        ? 'TikTok Video URL'
                        : 'Instagram Video URL',
                  ),
                ),
                SizedBox(height: 20),
                _downloading
                    ? const CenterProgressIndicator()
                    : CustomElevatedBtn(
                        label: 'Download Instagram Video',
                        onPressed: () {
                          final videoUrl = genericVideoLinkController.text;

                          if (videoUrl.isNotEmpty) {
                            if (platform == "tiktok") {
                              fetchTikTokVideo(videoUrl);
                            } else {
                              _fetchInstagramVideo(videoUrl);
                            }
                            Navigator.pop(context);
                          }
                        },
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchInstagramVideo(String videoUrl) async {
    final url = Uri.parse(
        'https://instagram-downloader-download-instagram-videos-stories1.p.rapidapi.com/?url=${Uri.encodeComponent(videoUrl)}');
    final headers = {
      'x-rapidapi-key': 'f73af0d298mshffd49671f08dbf3p1e74f9jsnfc39709e2678',
      // 'x-rapidapi-key': '3297f196e6msha861d4907c79366p16c044jsnbfd4786c6006',
      'x-rapidapi-host':
          'instagram-downloader-download-instagram-videos-stories1.p.rapidapi.com',
    };

    setState(() {
      _downloading = true;
    });

    try {
      final response = await http.get(url, headers: headers);
      print('::: ${response.body}');
      print('::: ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is List && responseData.isNotEmpty) {
          final videoData = responseData[0];

          // Optionally, save the video file to local storage
          await _downloadFile(videoData['url'], 'video.mp4');
          genericVideoLinkController.clear();
        }
      }
    } catch (e) {
      print(':::Error downloading video: $e');
    } finally {
      setState(() {
        _downloading = false;
      });
    }
  }

  Future<void> fetchTikTokVideo(var videoUrl) async {
    const url =
        "https://tiktok-download-without-watermark.p.rapidapi.com/analysis";
    setState(() {
      _downloadingtiktok = true;
    });
    try {
      final response = await http.get(
        Uri.parse("$url?url=$videoUrl&hd=0"),
        headers: {
          "x-rapidapi-key":
              "652fc95660msh4825c876ba3276bp12a6b1jsnd1d5785bdd60",
          "x-rapidapi-host": "tiktok-download-without-watermark.p.rapidapi.com",
        },
      );

      print('::: tiktok vidoe  ${response.body}');
      print('::: tiktok vidoe  ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Access the download link from the response
        final downloadLink = data['data']['play'];
        print(':::Download Link: $downloadLink');
        _downloadFile(downloadLink, 'video.mp4');
      } else {
        setState(() {
          _downloadingtiktok = false;
        });
        print(':::Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print(':::Error downloading video: $e');
    } finally {
      setState(() {
        _downloading = false;
      });
    }
  }

  Future<void> _downloadFile(String url, String filename) async {
    final response = await http.get(Uri.parse(url));
    print(':::_downloadFile ${response.body}');
    print('::: _downloadFile${response.statusCode}');
    if (response.statusCode == 200) {
      final appPath = await DirHelper.getAppPath();
      final filePath = '$appPath/$filename';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      print('::: Video saved to $filePath');

      print(':::: saving this file$filePath');
      await saveVideoToGallery(filePath);

      setState(() {
        _downloadingtiktok = false;
      });
      _startVideoEditorInPipModeForInsta(filePath);
    } else {
      print('::: Failed to download file');
    }
  }

  static Future<void> saveVideoToGallery(videoPath) async {
    // await GallerySaver.saveVideo(videoPath, albumName: 'TikTok_downloads');
    final result = await SaverGallery.saveFile(
        file: videoPath,
        androidExistNotSave: true,
        name: '123.mp4',
        androidRelativePath: "Movies");
    print(result);
  }

  @override
  void dispose() {
    genericVideoLinkController.dispose();
    _intentMediaStreamSubscription.cancel();
    _intentTextStreamSubscription.cancel();
    super.dispose();
  }
}
