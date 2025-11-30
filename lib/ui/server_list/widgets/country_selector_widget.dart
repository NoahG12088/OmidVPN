import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omidvpn/ui/server_list/controller/server_list_controller.dart';
import 'package:omidvpn/ui/server_list/providers/selected_country_provider.dart';

class CountrySelectorWidget extends ConsumerWidget {
  const CountrySelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverList = ref.watch(serverListAsyncNotifier);
    final selectedCountry = ref.watch(selectedCountryProvider);

    return serverList.when(
      data: (servers) {
        final countryMap = <String, String>{};
        int premiumServerCount = 0;
        
        for (final server in servers) {
          if (server.countryShort.isNotEmpty && server.countryLong.isNotEmpty) {
            countryMap[server.countryShort] = server.countryLong;
          }
          
          // Count premium servers (those with "pro-server" hostname)
          if (server.hostName.toLowerCase().contains('pro')) {
            premiumServerCount++;
          }
        }

        final sortedCountries = countryMap.keys.toList()..sort();

        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sortedCountries.length + 1 + (premiumServerCount > 0 ? 1 : 0), // +1 for "All Countries" and +1 for "Premium" if exists
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              // First item: "All Countries"
              if (index == 0) {
                return FilterChip(
                  label: const Text('All Countries'),
                  selected: selectedCountry == null,
                  onSelected: (_) {
                    ref
                        .read(serverListAsyncNotifier.notifier)
                        .filterByCountry(null);
                  },
                );
              }
              
              // Second item: "Premium" (if there are premium servers)
              if (index == 1 && premiumServerCount > 0) {
                return FilterChip(
                  label: const Text('Premium'),
                  selected: selectedCountry == 'PREMIUM',
                  onSelected: (_) {
                    ref
                        .read(serverListAsyncNotifier.notifier)
                        .filterByCountry('PREMIUM');
                  },
                );
              }
              
              // Country items
              final adjustedIndex = index - 1 - (premiumServerCount > 0 ? 1 : 0);
              if (adjustedIndex >= sortedCountries.length) {
                // This shouldn't happen, but just in case
                return const SizedBox();
              }
              
              final countryShort = sortedCountries[adjustedIndex];
              final countryLong = countryMap[countryShort] ?? countryShort;
              return FilterChip(
                label: Text(countryLong),
                selected:
                    selectedCountry?.toLowerCase() == countryShort.toLowerCase(),
                onSelected: (_) {
                  ref
                      .read(serverListAsyncNotifier.notifier)
                      .filterByCountry(countryShort);
                },
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}