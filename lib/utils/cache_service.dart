import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheService extends WidgetsBindingObserver {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() {
    return _instance;
  }
  CacheService._internal();
  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      _clearImageCache();
    }
  }

  void _clearImageCache() {
    DefaultCacheManager().emptyCache();
  }
}
