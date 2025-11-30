import 'dart:convert';

import 'package:omidvpn/api/domain/entity/server_info.dart';
import 'package:omidvpn/api/domain/repository/vpn_repository.dart';
import 'package:omidvpn/ui/server_list/data/data_source/json_server_source.dart';
import 'package:omidvpn/ui/server_list/data/mapper/json_server_list_mapper.dart';
import 'package:omidvpn/ui/shared/one_day_cache.dart';

class JsonServerRepository implements VpnRepository {
  final JsonServerRemoteSource remoteSource;
  final OneDayFileCacheManager localSource;
  final List<JsonServerRemoteSource> additionalSources;

  final String _cacheKey;

  JsonServerRepository({
    required this.remoteSource,
    required this.localSource,
    this.additionalSources = const [],
    required cacheKey,
  }) : _cacheKey = cacheKey;

  @override
  Future<List<ServerInfo>> getServerList({
    bool forceRefresh = false,
    bool getCache = false,
  }) async {
    assert((forceRefresh && getCache) != true);

    final String? cachedJson = await localSource.read(
      key: _cacheKey,
      getExpired: getCache,
    );
    if (cachedJson != null && !forceRefresh) {
      final List<dynamic> jsonData = cachedJson.startsWith('[')
          ? (jsonDecode(cachedJson) as List<dynamic>)
          : [];
      return JsonServerListMapper.fromJson(jsonData: jsonData);
    }

    // Fetch data from primary source
    final List<dynamic> primaryData = await remoteSource.getServerList();
    
    // Fetch data from additional sources
    List<dynamic> combinedData = List.from(primaryData);
    
    for (final source in additionalSources) {
      try {
        final additionalData = await source.getServerList();
        combinedData.addAll(additionalData);
      } catch (e) {
        // Continue with other sources if one fails
        continue;
      }
    }

    final jsonString = jsonEncode(combinedData);
    localSource.save(key: _cacheKey, content: jsonString);
    return JsonServerListMapper.fromJson(jsonData: combinedData);
  }
}