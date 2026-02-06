import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin / Engineer Portal'),
        actions: [IconButton(icon: const Icon(Icons.code), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Device Cards
              _deviceCard(
                title: 'Downstream Arduino ESP32',
                id: 'ARD-ESP32-001',
                battery: 78,
                signal: 8,
                dataRate: '1 min',
                firmware: 'v2.4.1',
                lastMaintenance: '15 days ago',
                nextCalibration: 'In 45 days',
                online: true,
              ),
              const SizedBox(height: 16),
              _deviceCard(
                title: 'Upstream Arduino ESP32',
                id: 'ARD-ESP32-002',
                battery: 92,
                signal: 9,
                dataRate: '1 min',
                firmware: 'v2.4.1',
                lastMaintenance: '15 days ago',
                nextCalibration: 'In 45 days',
                online: true,
              ),
              const SizedBox(height: 32),
              // Real-Time Monitoring
              _realTimeMonitoringSection(),
              const SizedBox(height: 32),
              // System Stats
              _systemStatsSection(),
              const SizedBox(height: 32),
              // Component Library (Alert Cards)
              _alertCardsSection(),
              const SizedBox(height: 32),
              // Emergency Buttons
              _emergencyButtonsSection(),
              const SizedBox(height: 32),
              // Dashboard Layouts
              _dashboardLayoutsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deviceCard({
    required String title,
    required String id,
    required int battery,
    required int signal,
    required String dataRate,
    required String firmware,
    required String lastMaintenance,
    required String nextCalibration,
    required bool online,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Icon(
                  Icons.circle,
                  color: online ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  online ? 'ONLINE' : 'OFFLINE',
                  style: TextStyle(color: online ? Colors.green : Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'ID: $id',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _infoBox('BATTERY', '$battery% Good', Colors.green),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _infoBox('SIGNAL', '$signal / 5', Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _infoBox('DATA RATE', dataRate, Colors.blue)),
                const SizedBox(width: 8),
                Expanded(child: _infoBox('FIRMWARE', firmware, Colors.blue)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Last Maintenance: $lastMaintenance'),
            Text('Next Calibration: $nextCalibration'),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('REBOOT')),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('FORCE TRANSMIT'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: () {}, child: const Text('TEST GSM')),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {},
                  child: const Text('EMERGENCY MODE'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _realTimeMonitoringSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Real-Time Monitoring',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _stationMonitor(
          'Upstream Station',
          3.1,
          5.0,
          0.01,
          62,
          'PREPARE',
          Colors.orange,
        ),
        _stationMonitor(
          'Midstream Station',
          4.2,
          5.0,
          0.3,
          84,
          'EVACUATE NOW',
          Colors.red,
        ),
        _stationMonitor(
          'Downstream Station',
          4.8,
          5.0,
          0.2,
          96,
          'EVACUATE NOW',
          Colors.red,
        ),
      ],
    );
  }

  Widget _stationMonitor(
    String name,
    double level,
    double max,
    double rate,
    int capacity,
    String status,
    Color statusColor,
  ) {
    return Card(
      color: statusColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle, color: Colors.green, size: 12),
                const SizedBox(width: 4),
                Text(name),
                const Spacer(),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${level.toStringAsFixed(1)} m / $max m',
                  style: TextStyle(fontSize: 18, color: statusColor),
                ),
                const Spacer(),
                Text(
                  'Updated: 1 min ago',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$capacity% capacity',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Text(
              '▲ ${rate.toStringAsFixed(2)} m/hr',
              style: const TextStyle(fontSize: 10, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _systemStatsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statBox('System Accuracy', '98.2%', Colors.green),
        _statBox('False Alert Rate', '1.3%', Colors.orange),
        _statBox('Avg Warning Time', '4.2 hrs', Colors.blue),
        _statBox('Sensor Uptime', '99.7%', Colors.green),
      ],
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _alertCardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Component Library',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _alertCard(
          'SAFE',
          'All Clear',
          'River levels are normal. No action required.',
          Colors.green,
          '5 min ago',
        ),
        _alertCard(
          'MONITOR',
          'Advisory Notice',
          'River levels rising. Continue monitoring.',
          Colors.orange,
          '3 min ago',
          affectedZones: 'Zone C',
        ),
        _alertCard(
          'PREPARE',
          'Prepare to Evacuate',
          'River approaching critical levels. Prepare emergency supplies.',
          Colors.orange,
          '1 min ago',
          affectedZones: 'Zone A, Zone B',
          expectedPeak: 'In 2 hours',
        ),
        _alertCard(
          'CRITICAL',
          'System Critical',
          'Multiple sensor failures detected. Manual monitoring required.',
          Colors.red,
          'Just now',
          acknowledge: true,
        ),
      ],
    );
  }

  Widget _alertCard(
    String level,
    String title,
    String description,
    Color color,
    String time, {
    String? affectedZones,
    String? expectedPeak,
    bool acknowledge = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                const Spacer(),
                Text(
                  time,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            if (affectedZones != null) ...[
              const SizedBox(height: 4),
              Text(
                'Affected Zones: $affectedZones',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            if (expectedPeak != null) ...[
              const SizedBox(height: 4),
              Text(
                'Expected Peak: $expectedPeak',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            if (acknowledge)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () {},
                  child: const Text('ACKNOWLEDGE'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _emergencyButtonsSection() {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {},
          child: const Text('Evacuate Now'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          onPressed: () {},
          child: const Text('Issue Alert'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {},
          child: const Text('Confirm Action'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100),
          onPressed: () {},
          child: const Text('PROCESSING...'),
        ),
      ],
    );
  }

  Widget _dashboardLayoutsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Colors.orange.shade100,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              'PREPARE TO EVACUATE - River levels rising rapidly',
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resident Dashboard',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Your Zone: Zone B (Medium Risk)',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        onPressed: () {},
                        child: const Text('Emergency Contact'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Command Center',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Barangay Emergency Operations',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                            ),
                            onPressed: () {},
                            child: const Text('Issue Alert'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {},
                            child: const Text('View Reports'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
