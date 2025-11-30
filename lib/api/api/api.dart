import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omidvpn/api/domain/entity/vpn_stage.dart';
import 'package:omidvpn/api/lang/en.dart';
import 'package:omidvpn/api/lang/lang.dart';
import 'package:omidvpn/ui/shared/openvpn_service.dart';
import 'package:omidvpn/ui/server_list/data/data_source/json_server_source.dart';
import 'package:omidvpn/ui/server_list/data/repository/json_server_repository.dart';
import 'package:omidvpn/ui/shared/one_day_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

final langProvider = Provider((ref) => LangEN());

// Theme mode provider
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadThemeMode();
    return state;
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('theme_mode') ?? 'system';
    
    switch (themeModeString) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      default:
        state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = themeMode;
    final prefs = await SharedPreferences.getInstance();
    
    String themeModeString;
    switch (themeMode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      default:
        themeModeString = 'system';
    }
    
    await prefs.setString('theme_mode', themeModeString);
  }
}

final oneDayFileCacheManagerProvider = FutureProvider(
  (ref) => OneDayFileCacheManager.create(appname: 'omidvpn', dirname: 'cache'),
);

final dioProvider = Provider((ref) => Dio());

final vpngateRepositoryProvider = FutureProvider((Ref ref) async {
  final dio = ref.watch(dioProvider);
  final cacheManager = await ref.watch(oneDayFileCacheManagerProvider.future);

  return JsonServerRepository(
    remoteSource: JsonServerRemoteSource(
      dio: dio,
      baseURL:
          'https://raw.githubusercontent.com/fdciabdul/Vpngate-Scraper-API/refs/heads/main/json/data.json',
    ),
    additionalSources: [
      JsonServerRemoteSource(
        dio: dio,
        baseURL:
            'https://raw.githubusercontent.com/code3-dev/omidvpn-api/refs/heads/master/api/index.json',
      ),
    ],
    localSource: cacheManager,
    cacheKey: 'json_servers.json',
  );
});

final openvpnServiceProvider = FutureProvider((ref) async {
  final cacheManager = await ref.watch(oneDayFileCacheManagerProvider.future);

  final openvpnService = OpenvpnService(
    cacheManager: cacheManager,
    configCipherFix: true,
    serverNameCacheKey: 'servername.txt',
    serverInfoCacheKey: 'serverinfo.txt',
  );

  openvpnService.ensureInitialized();

  return openvpnService;
});

final vpnStageProvider = StreamProvider<VpnStage>((ref) async* {
  final openvpnService = await ref.watch(openvpnServiceProvider.future);
  await for (final value in openvpnService.stageStream) {
    yield value;
  }
});