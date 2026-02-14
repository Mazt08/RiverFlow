import 'package:flutter/material.dart';

class OfficialDashboardPage extends StatelessWidget {
  const OfficialDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6B6767),
      appBar: AppBar(
        title: const Text('Official'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Barangay Official Dashboard',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('All Monitoring Stations'),
              const SizedBox(height: 12),
              _stationCard(
                title: 'Upstream Station',
                id: 'RIV-001',
                alert: 'MONITOR',
                alertColor: Colors.amber,
                level: 3.1,
                percent: 0.62,
                trend: 0.1,
                trendColor: Colors.red,
                arduinoStatus: 'Online',
                battery: 85,
                batteryColor: Colors.green,
                updated: '2 min ago',
              ),
              _stationCard(
                title: 'Midstream Station',
                id: 'RIV-002',
                alert: 'EVACUATE',
                alertColor: Colors.red,
                level: 4.2,
                percent: 0.84,
                trend: 0.3,
                trendColor: Colors.red,
                arduinoStatus: 'Online',
                battery: 72,
                batteryColor: Colors.green,
                updated: '1 min ago',
              ),
              _stationCard(
                title: 'Downstream Station',
                id: 'RIV-003',
                alert: 'EVACUATE',
                alertColor: Colors.red,
                level: 4.8,
                percent: 0.96,
                trend: 0.2,
                trendColor: Colors.red,
                arduinoStatus: 'Low Battery',
                battery: 18,
                batteryColor: Colors.orange,
                updated: '30 sec ago',
              ),
              const SizedBox(height: 16),
              _actionButton(
                'Issue Evacuation Order',
                Colors.red,
                Icons.campaign,
              ),
              _actionButton('Send SMS Blast', Colors.amber, Icons.sms),
              _actionButton(
                'Activate Sirens',
                Colors.orange,
                Icons.notifications_active,
              ),
              const SizedBox(height: 16),
              _evacuationCoordinationCard(),
              const SizedBox(height: 16),
              _floodRiskZonesCard(),
              const SizedBox(height: 16),
              _evacuationCentersCard(),
              const SizedBox(height: 16),
              _safeRoutesCard(),
              const SizedBox(height: 16),
              _componentLibraryCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stationCard({
    required String title,
    required String id,
    required String alert,
    required Color alertColor,
    required double level,
    required double percent,
    required double trend,
    required Color trendColor,
    required String arduinoStatus,
    required int battery,
    required Color batteryColor,
    required String updated,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Icon(Icons.circle, color: alertColor, size: 20),
              ],
            ),
            Text('ID: $id'),
            Row(
              children: [
                const Text('ALERT: '),
                Text(
                  alert,
                  style: TextStyle(
                    color: alertColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text('LEVEL: '),
                Text(
                  '${level.toStringAsFixed(1)} m',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            LinearProgressIndicator(
              value: percent,
              color: alertColor,
              backgroundColor: Colors.grey[200],
            ),
            Row(
              children: [
                const Text('TREND: '),
                Icon(Icons.arrow_upward, color: trendColor, size: 16),
                Text(
                  '${trend.toStringAsFixed(1)} m/hr',
                  style: TextStyle(color: trendColor),
                ),
              ],
            ),
            Row(
              children: [
                const Text('ARDUINO: '),
                Icon(
                  Icons.circle,
                  color: arduinoStatus == 'Online'
                      ? Colors.green
                      : Colors.orange,
                  size: 12,
                ),
                Text(' $arduinoStatus'),
              ],
            ),
            Row(
              children: [
                const Text('BATTERY: '),
                Icon(Icons.battery_full, color: batteryColor, size: 16),
                Text(' $battery%'),
              ],
            ),
            Text(
              'Updated: $updated',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size.fromHeight(48),
        ),
        onPressed: () {},
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _evacuationCoordinationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Evacuation Coordination',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Map and evacuation center info here (see documentation for details).',
            ),
          ],
        ),
      ),
    );
  }

  Widget _floodRiskZonesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Flood Risk Zones',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Zone A (Critical), Zone B (High), Zone C (Medium), Zone D (Low)',
            ),
          ],
        ),
      ),
    );
  }

  Widget _evacuationCentersCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Evacuation Centers',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Barangay Hall, Elementary School, Community Center'),
          ],
        ),
      ),
    );
  }

  Widget _safeRoutesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Safe Routes', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              'Main Road (Open), Highway 101 (Congested), River Bridge (Closed)',
            ),
          ],
        ),
      ),
    );
  }

  Widget _componentLibraryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Component Library',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Alert cards, emergency buttons, dashboard layouts, etc.'),
          ],
        ),
      ),
    );
  }
}
