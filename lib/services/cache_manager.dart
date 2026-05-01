import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AppCacheManager {
  static const _key = 'keybricks_img_cache';

  static final instance = CacheManager(
    Config(
      _key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 200,
    ),
  );
}
