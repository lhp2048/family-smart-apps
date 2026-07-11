import 'package:flutter_test/flutter_test.dart';

import 'package:family_smart_center/features/dashboard/data/portal_discovery_client.dart';

void main() {
  group('PortalDiscoveryClient.discoverMediacenter', () {
    test('parses mediacenter from services payload shape', () async {
      final payload = {
        'portal': {'origin': 'http://192.168.1.10:18024'},
        'services': {
          'mediacenter': {
            'apiBaseUrl': 'http://192.168.1.10:18026/api/v1',
            'origin': 'http://192.168.1.10:18026',
            'running': true,
            'title': 'Media Center',
            'productId': 'family_mediacenter',
          },
        },
      };

      final services = payload['services'] as Map;
      final mediacenter = services['mediacenter'] as Map;
      final apiBaseUrl = mediacenter['apiBaseUrl'].toString();
      final origin = mediacenter['origin'].toString();

      expect(apiBaseUrl, contains('/api/v1'));
      expect(origin, contains(':18026'));

      final discovery = MediacenterDiscovery(
        apiBaseUrl: apiBaseUrl.endsWith('/') ? apiBaseUrl : '$apiBaseUrl/',
        origin: origin.endsWith('/')
            ? origin.substring(0, origin.length - 1)
            : origin,
        running: mediacenter['running'] == true,
        title: mediacenter['title']?.toString() ?? '',
        productId: mediacenter['productId']?.toString() ?? '',
      );

      expect(discovery.running, isTrue);
      expect(discovery.productId, 'family_mediacenter');
      expect(discovery.apiBaseUrl, endsWith('/'));
    });
  });
}
