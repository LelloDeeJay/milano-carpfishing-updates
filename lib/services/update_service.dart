import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateInfo {
  final String versione;
  final String urlDownload;
  final String note;

  UpdateInfo({required this.versione, required this.urlDownload, required this.note});
}

class UpdateService {
  static const String repo = 'LelloDeeJay/milano-carpfishing-updates';

  static int _num(String v) {
    final parti = v.replaceAll('v', '').split('.');
    var n = 0;
    for (final p in parti) {
      n = n * 1000 + (int.tryParse(p) ?? 0);
    }
    return n;
  }

  static Future<UpdateInfo?> checkUpdate() async {
    try {
      final res = await http.get(
        Uri.parse('https://api.github.com/repos/$repo/releases/latest'),
        headers: {'Accept': 'application/vnd.github+json'},
      );
      if (res.statusCode != 200) return null;
      final j = jsonDecode(res.body);
      final tag = (j['tag_name'] ?? '').toString().replaceAll('v', '');
      final assets = (j['assets'] as List<dynamic>? ?? []);
      String url = '';
      for (final a in assets) {
        final name = (a['name'] ?? '').toString();
        if (name.endsWith('.apk')) {
          url = (a['browser_download_url'] ?? '').toString();
          break;
        }
      }
      if (url.isEmpty && assets.isNotEmpty) {
        url = (assets[0]['browser_download_url'] ?? '').toString();
      }
      final info = await PackageInfo.fromPlatform();
      if (tag.isEmpty || url.isEmpty) return null;
      if (_num(tag) <= _num(info.version)) return null;
      return UpdateInfo(
        versione: tag,
        urlDownload: url,
        note: (j['body'] ?? '').toString(),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<void> apriDownload(String url) async {
    final u = Uri.parse(url);
    if (await canLaunchUrl(u)) {
      await launchUrl(u, mode: LaunchMode.externalApplication);
    }
  }
}
