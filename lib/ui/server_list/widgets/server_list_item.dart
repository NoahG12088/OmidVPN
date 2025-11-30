import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omidvpn/api/api/api.dart';
import 'package:omidvpn/api/domain/entity/server_info.dart';

class ServerListItem extends ConsumerWidget {
  final ServerInfo server;
  final VoidCallback onSelect;

  const ServerListItem({
    super.key,
    required this.server,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: SizedBox(
          width: 60,
          height: 40,
          child: (() {
            final countryCode = server.countryShort.toLowerCase();
            final flagAssetPath = 'assets/CountryFlags/$countryCode.png';
            return Image.asset(
              flagAssetPath,
              errorBuilder: (context, error, stackTrace) {
                // Show a default flag or empty container if flag not found
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.flag, size: 20),
                );
              },
              fit: BoxFit.contain,
            );
          })(),
        ),
        title: Row(
          children: [
            Text(
              server.hostName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            // Show a "Premium" badge for premium servers
            if (server.hostName.toLowerCase().contains('pro'))
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Premium',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, size: 16),
                const SizedBox(width: 4),
                Text('${server.numVpnSessions} ${lang.sessions}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Text('${server.uptime} ${lang.days}'),
              ],
            ),
            const SizedBox(height: 4),
            // Show country abbreviation instead of speed
            Row(
              children: [
                Icon(Icons.flag, size: 16),
                const SizedBox(width: 4),
                Text('${server.countryShort}'),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            server.countryShort,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: onSelect,
      ),
    );
  }
}