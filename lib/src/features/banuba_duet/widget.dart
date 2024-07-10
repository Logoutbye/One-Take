import 'package:flutter/material.dart';
import 'package:flutter_ve_sdk/src/core/utils/app_assets.dart';
import 'package:flutter_ve_sdk/src/core/utils/app_colors.dart';


class DownloaderBodyLogo extends StatelessWidget {
  const DownloaderBodyLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(.1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: const Image(
        width: 100,
        height: 100,
        image: AssetImage(AppAssets.tikTokLogo),
      ),
    );
  }
}

class InstaLogo extends StatelessWidget {
  const InstaLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(.1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: const Image(
        width: 100,
        height: 100,
        image: AssetImage(AppAssets.instaLogo),
      ),
    );
  }
}
