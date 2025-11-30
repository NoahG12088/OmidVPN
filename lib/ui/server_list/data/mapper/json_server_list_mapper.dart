import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:omidvpn/api/domain/entity/server_info.dart';

sealed class JsonServerListMapper {
  static String _decodeVpnConfig(String base64String) {
    try {
      // Clean the base64 string by removing any invalid characters
      final cleanedBase64 = base64String.replaceAll(
        RegExp(r'[^A-Za-z0-9+/=]'),
        '',
      );

      // Ensure proper padding
      final paddedBase64 = _padBase64String(cleanedBase64);

      // Decode the base64 string
      final decodedBytes = base64Decode(paddedBase64);

      // Convert bytes to UTF-8 string
      return utf8.decode(decodedBytes, allowMalformed: true);
    } catch (e) {
      debugPrint('Error decoding VPN config: $e');
      return '';
    }
  }

  static String _padBase64String(String base64String) {
    final padLength = (4 - (base64String.length % 4)) % 4;
    return base64String + '=' * padLength;
  }

  static List<ServerInfo> fromJson({required List<dynamic> jsonData}) {
    List<ServerInfo> list = [];

    try {
      // Handle both formats: array of objects and array of arrays with "servers" key
      for (int i = 0; i < jsonData.length; i++) {
        if (jsonData[i] is Map<String, dynamic>) {
          // Check if this is the new format with "servers" array
          if ((jsonData[i] as Map<String, dynamic>).containsKey('servers')) {
            final serversData = (jsonData[i] as Map<String, dynamic>)['servers'] as List<dynamic>;
            
            for (int j = 0; j < serversData.length; j++) {
              try {
                final server = serversData[j] as Map<String, dynamic>;

                // Skip servers with empty hostname or IP
                if ((server['hostname'] as String? ?? '').isEmpty ||
                    (server['ip'] as String? ?? '').isEmpty) {
                  continue;
                }

                list.add(
                  ServerInfo(
                    hostName: server['hostname'] as String? ?? '',
                    ip: server['ip'] as String? ?? '',
                    score: int.tryParse(server['score'].toString()) ?? 0,
                    ping: int.tryParse(server['ping'].toString()) ?? -1,
                    speed: double.tryParse(server['speed'].toString())?.round() ?? 0,
                    countryLong: server['countrylong'] as String? ?? '',
                    countryShort: server['countryshort'] as String? ?? '',
                    numVpnSessions:
                        int.tryParse(server['numvpnsessions'].toString()) ?? 0,
                    uptime: double.tryParse(server['uptime'].toString())?.round() ?? 0,
                    totalUsers: int.tryParse(server['totalusers'].toString()) ?? 0,
                    totalTraffic:
                        double.tryParse(server['totaltraffic'].toString())?.round() ?? 0,
                    logType: server['logtype'] as String? ?? '',
                    operator: server['operator'] as String? ?? '',
                    message: server['message'] as String? ?? '',
                    vpnConfig: _decodeVpnConfig(
                      server['openvpn_configdata_base64'] as String? ?? '',
                    ),
                  ),
                );
              } catch (serverError) {
                debugPrint('Error parsing server at index $j: $serverError');
                continue;
              }
            }
          } else {
            // Handle the original format directly
            try {
              final server = jsonData[i] as Map<String, dynamic>;

              // Skip servers with empty hostname or IP
              if ((server['hostname'] as String? ?? '').isEmpty ||
                  (server['ip'] as String? ?? '').isEmpty) {
                continue;
              }

              list.add(
                ServerInfo(
                  hostName: server['hostname'] as String? ?? '',
                  ip: server['ip'] as String? ?? '',
                  score: int.tryParse(server['score'].toString()) ?? 0,
                  ping: int.tryParse(server['ping'].toString()) ?? -1,
                  speed: double.tryParse(server['speed'].toString())?.round() ?? 0,
                  countryLong: server['countrylong'] as String? ?? '',
                  countryShort: server['countryshort'] as String? ?? '',
                  numVpnSessions:
                      int.tryParse(server['numvpnsessions'].toString()) ?? 0,
                  uptime: double.tryParse(server['uptime'].toString())?.round() ?? 0,
                  totalUsers: int.tryParse(server['totalusers'].toString()) ?? 0,
                  totalTraffic:
                      double.tryParse(server['totaltraffic'].toString())?.round() ?? 0,
                  logType: server['logtype'] as String? ?? '',
                  operator: server['operator'] as String? ?? '',
                  message: server['message'] as String? ?? '',
                  vpnConfig: _decodeVpnConfig(
                    server['openvpn_configdata_base64'] as String? ?? '',
                  ),
                ),
              );
            } catch (serverError) {
              debugPrint('Error parsing server at index $i: $serverError');
              continue;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error parsing JSON data: $e');
    }

    return list;
  }
}