import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omidvpn/api/api/api.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenSourceLicensesScreen extends ConsumerWidget {
  const OpenSourceLicensesScreen({super.key});

  // Function to launch URLs
  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      // Show error message to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);

    final List<Map<String, String>> licenses = [
      {
        'name': 'Flutter',
        'license': 'BSD 3-Clause License',
        'url': 'https://github.com/flutter/flutter',
      },
      {
        'name': 'Material 3',
        'license': 'Apache License 2.0',
        'url': 'https://m3.material.io/',
      },
      {
        'name': 'Android',
        'license': 'Apache License 2.0',
        'url': 'https://source.android.com/',
      },
      {
        'name': 'OpenVPN',
        'license': 'GPLv2 License',
        'url': 'https://openvpn.net/',
      },
      {
        'name': 'OpenVPN for Android',
        'license': 'GPLv2 License',
        'url': 'https://github.com/schwabe/ics-openvpn',
      },
      {
        'name': 'Riverpod',
        'license': 'MIT License',
        'url': 'https://github.com/rrousselGit/riverpod',
      },
      {
        'name': 'Dio',
        'license': 'MIT License',
        'url': 'https://github.com/flutterchina/dio',
      },
      {
        'name': 'Shared Preferences',
        'license': 'BSD 3-Clause License',
        'url': 'https://pub.dev/packages/shared_preferences',
      },
      {
        'name': 'Package Info Plus',
        'license': 'BSD 3-Clause License',
        'url': 'https://pub.dev/packages/package_info_plus',
      },
      {
        'name': 'URL Launcher',
        'license': 'BSD 3-Clause License',
        'url': 'https://pub.dev/packages/url_launcher',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Open Source Licenses'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
        itemCount: licenses.length,
        itemBuilder: (context, index) {
          final license = licenses[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(license['name']!),
              subtitle: Text(license['license']!),
              trailing: Icon(Icons.open_in_browser),
              onTap: () {
                _launchUrl(context, license['url']!);
              },
            ),
          );
        },
      ),
    );
  }
}