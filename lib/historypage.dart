import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'alert_model.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';

Future<String> getCityCountry(double lat, double lng) async {
  try {
    final placemarks = await placemarkFromCoordinates(lat, lng);
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      // Tenta cidade, senão sublocalidade, senão estado, senão país
      final cidade =
          place.locality?.isNotEmpty == true
              ? place.locality
              : (place.subAdministrativeArea?.isNotEmpty == true
                  ? place.subAdministrativeArea
                  : (place.administrativeArea?.isNotEmpty == true
                      ? place.administrativeArea
                      : null));
      final pais = place.country ?? '';
      if (cidade != null && cidade != pais) {
        return '$cidade, $pais';
      } else {
        return pais;
      }
    }
  } catch (e) {
    print('Erro ao obter cidade/país: $e');
  }
  return 'Localização desconhecida';
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    final alertsBox = Hive.box<Alert>('alertsBox');

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Alertas')),
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
              final alert = box.getAt(index)!;
              final date = DateFormat(
                'dd/MM/yyyy HH:mm',
              ).format(DateTime.parse(alert.dateTime));
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.grey[100],
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ExpansionTile(
                  key: Key('$index'),
                  initiallyExpanded: expandedIndex == index,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      expandedIndex = expanded ? index : null;
                    });
                  },
                  title: Column(
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
                        'Bateria: ${alert.batteryLevel}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(alert.latitude, alert.longitude),
                          zoom: 16,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId('alert_$index'),
                            position: LatLng(alert.latitude, alert.longitude),
                          ),
                        },
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                        liteModeEnabled: false, // mais leve para histórico
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            // Exemplo: mostrar detalhes em um dialog
                            showDialog(
                              context: context,
                              builder: (context) {
                                final imagePaths = alert.photos;
                                final dialogWidth =
                                    MediaQuery.of(context).size.width * 0.95;
                                final dialogHeight =
                                    MediaQuery.of(context).size.height * 0.65;
                                return AlertDialog(
                                  title: const Text('Detalhes do Alerta'),
                                  content: SizedBox(
                                    width: dialogWidth,
                                    height: dialogHeight,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Data: $date\n'
                                          'Localização: ${alert.latitude}, ${alert.longitude}\n'
                                          'Bateria: ${alert.batteryLevel}',
                                        ),
                                        const SizedBox(height: 16),
                                        if (imagePaths.isNotEmpty)
                                          SizedBox(
                                            height:
                                                dialogHeight *
                                                0.8, 
                                            width:
                                                dialogWidth *
                                                0.9, 
                                            child: PageView.builder(
                                              itemCount: imagePaths.length,
                                              itemBuilder: (context, imgIndex) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                      ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    child: Image.file(
                                                      File(
                                                        imagePaths[imgIndex],
                                                      ),
                                                      fit:
                                                          BoxFit
                                                              .contain, // ou BoxFit.cover, se preferir preencher
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) => const Icon(
                                                            Icons.broken_image,
                                                            size: 80,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        else
                                          const Text(
                                            'Sem imagens para este alerta.',
                                          ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Fechar'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.info_outline),
                          label: const Text('Detalhes'),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () {
                            // Apagar alerta
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Apagar Alerta'),
                                    content: const Text(
                                      'Tem certeza que deseja apagar este alerta?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          final alertsBox = Hive.box<Alert>(
                                            'alertsBox',
                                          );
                                          alertsBox.deleteAt(index);
                                          Navigator.pop(context);
                                          setState(() => expandedIndex = null);
                                        },
                                        child: const Text('Apagar'),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Apagar'),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () {
                            setState(() => expandedIndex = null);
                          },
                          icon: const Icon(Icons.expand_less),
                          label: const Text('Recolher'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
