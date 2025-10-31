import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const ApuestaGoleadoraApp());
}

class ApuestaGoleadoraApp extends StatelessWidget {
  const ApuestaGoleadoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Apuesta Goleadora ⚽',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF8F3FF),
      ),
      home: const ApuestaScreen(),
    );
  }
}

class ApuestaScreen extends StatefulWidget {
  const ApuestaScreen({super.key});

  @override
  State<ApuestaScreen> createState() => _ApuestaScreenState();
}

class _ApuestaScreenState extends State<ApuestaScreen> {
  Map<String, Map<String, dynamic>> jugadores = {
    'Juan': {
      'nombre': 'Luis Suárez',
      'club': 'Sporting CP',
      'goles': 0,
      'asistencias': 0,
      'partidos': 0,
    },
    'Adolfo': {
      'nombre': 'Dušan Vlahović',
      'club': 'Juventus',
      'goles': 0,
      'asistencias': 0,
      'partidos': 0,
    },
    'Yeye': {
      'nombre': 'Kylian Mbappé',
      'club': 'Real Madrid',
      'goles': 0,
      'asistencias': 0,
      'partidos': 0,
    },
  };

  String getLider() {
    var mayor = jugadores.entries.reduce(
        (a, b) => a.value['goles'] > b.value['goles'] ? a : b);
    return mayor.key;
  }

  Future<void> actualizarGoles() async {
    try {
      final data = await rootBundle.loadString('assets/goles.json');
      final Map<String, dynamic> golesJson = json.decode(data);

      setState(() {
        jugadores.forEach((jugador, info) {
          final nombre = info['nombre'];
          if (golesJson.containsKey(nombre)) {
            info['goles'] = golesJson[nombre]['goles'] ?? 0;
            info['asistencias'] = golesJson[nombre]['asistencias'] ?? 0;
            info['partidos'] = golesJson[nombre]['partidos'] ?? 0;
          }
        });
      });

      print('✅ Goles actualizados desde archivo local');
    } catch (e) {
      print('❌ Error al leer goles.json: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lider = getLider();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apuesta Goleadora ⚽'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var entry in jugadores.entries)
              Card(
                elevation: 4,
                color: entry.key == lider
                    ? const Color(0xFFFFF5CC) // dorado suave
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: entry.key == lider
                      ? const Text("🏆", style: TextStyle(fontSize: 20))
                      : const Text("⚽", style: TextStyle(fontSize: 20)),
                  title: Text(
                    '${entry.key} - ${entry.value['nombre']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(entry.value['club']),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Goles: ${entry.value['goles']}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Asistencias: ${entry.value['asistencias']}'),
                      Text('Partidos: ${entry.value['partidos']}'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              '🏅 Lidera: $lider',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                await actualizarGoles();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar goles'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}