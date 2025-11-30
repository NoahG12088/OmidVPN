part of 'server_list_controller.dart';

mixin ServerListState {
  AsyncValue<List<ServerInfo>> serverListState(WidgetRef ref) =>
      ref.watch(serverListAsyncNotifier);

  AsyncValue<List<ServerInfo>> filteredServerListState(WidgetRef ref) {
    final serverList = ref.watch(serverListAsyncNotifier);
    final selectedCountry = ref.watch(selectedCountryProvider);

    return serverList.whenData((servers) {
      // Sort all servers by uptime (days) in ascending order
      // But put premium servers first
      final sortedServers = List<ServerInfo>.from(servers)
        ..sort((a, b) {
          // Check if servers are premium
          final aIsPremium = a.hostName.toLowerCase().contains('pro');
          final bIsPremium = b.hostName.toLowerCase().contains('pro');
          
          // If one is premium and the other isn't, premium comes first
          if (aIsPremium && !bIsPremium) return -1;
          if (!aIsPremium && bIsPremium) return 1;
          
          // If both are premium or both are not premium, sort by uptime
          return toDays(a.uptime).compareTo(toDays(b.uptime));
        });

      // If "Premium" is selected, show only premium servers
      if (selectedCountry == 'PREMIUM') {
        return sortedServers
            .where((server) => server.hostName.toLowerCase().contains('pro'))
            .toList();
      }

      // If a specific country is selected, filter by that country
      if (selectedCountry != null) {
        return sortedServers
            .where(
              (server) =>
                  server.countryShort.toLowerCase() ==
                  selectedCountry.toLowerCase(),
            )
            .toList();
      }
      
      // Otherwise, show all servers (with premium servers at the top)
      return sortedServers;
    });
  }

  int toMegaBytes(int bytes) {
    return (bytes / 1000 / 1000).round();
  }

  int toDays(int milliseconds) {
    return (milliseconds / 1000 / 60 / 60 / 24).round();
  }
}