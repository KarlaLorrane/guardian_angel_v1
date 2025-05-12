import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> alerts = [
      {
        'title': 'Emergency Alert',
        'location': 'Downtown',
        'time': '2 hrs ago',
      },
      {
        'title': 'Medical Assistance',
        'location': 'Home',
        'time': 'Yesterday',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert History'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: Colors.grey[100],
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Detalhes do alerta
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['title']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Location: ${alert['location']}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  // Tempo
                  Text(
                    alert['time']!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
