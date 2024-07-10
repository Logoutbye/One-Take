import 'package:flutter/material.dart';
import 'package:flutter_ve_sdk/src/features/banuba_duet/home_duet.dart';
import '../features/splash/splash_screen.dart';


class Routes {
  static const String splash = "/splash";
  static const String downloader = "/downloader";
  static const String downloads = "/downloads";
  static const String viewVideo = "/viewVideo";
}

class AppRouter {
  static Route? getRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.splash:
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        );

      case Routes.downloader:
        return MaterialPageRoute(
          builder: (context) => const HomeDuet(),
        );
      // case Routes.downloads:
      //   return MaterialPageRoute(
      //     builder: (context) => const DownloadsScreen(),
      //   );
      // case Routes.viewVideo:
      //   return MaterialPageRoute(
      //     builder: (context) => VideoPlayerView(
      //       videoPath: routeSettings.arguments as String,
      //     ),
      //   );
    }
    return null;
  }
}
