import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'alert_model.dart';
import 'package:intl/intl.dart'; // Para formatar data
import 'package:geocoding/geocoding.dart';

// Função para converter coordenadas em cidade e país
Future<String> getCityCountry(double lat, double lng) async {
  try {
    final placemarks = await placemarkFromCoordinates(lat, lng);
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      return '${place.locality ?? ''}, ${place.country ?? ''}';
    }
  } catch (_) {}
  return 'Localização desconhecida';
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final alertsBox = Hive.box<Alert>('alertsBox');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Alertas'),
      ),
      body: ValueListenableBuilder(
        valueListenable: alertsBox.listenable(),
        builder: (context, Box<Alert> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('Nenhum alerta registrado.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final alert = box.getAt(index);
              // Formata a data
              final date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(alert!.dateTime));
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.grey[100],
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alerta em: $date',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<String>(
                        future: getCityCountry(alert.latitude, alert.longitude),
                        builder: (context, snapshot) {
                          final localizacao = snapshot.data ?? 'Carregando...';
                          return Text(
                            'Localização: $localizacao',
                            style: const TextStyle(color: Colors.grey),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bateria: ${alert.batteryLevel}%',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}