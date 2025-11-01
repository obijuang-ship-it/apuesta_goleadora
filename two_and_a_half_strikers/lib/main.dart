import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const TwoAndAHalfStrikersApp());
}

class TwoAndAHalfStrikersApp extends StatelessWidget {
  const TwoAndAHalfStrikersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Two and a Half Strikers ⚽',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF7FAF8),
      ),
      home: const StrikersScreen(),
    );
  }
}

class StrikersScreen extends StatefulWidget {
  const StrikersScreen({super.key});

  @override
  State<StrikersScreen> createState() => _StrikersScreenState();
}

class _StrikersScreenState extends State<StrikersScreen>
    with SingleTickerProviderStateMixin {
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

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
            .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();

    actualizarGoles();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    final sorted = jugadores.entries.toList()
      ..sort((a, b) => b.value['goles'].compareTo(a.value['goles']));

    return Scaffold(
      body: Column(
        children: [
          // Cabecera animada
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00864B), Color(0xFF0C4E27)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: const Text(
                  'Two and a Half Strikers ⚽',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Lista de jugadores
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: sorted.length,
                itemBuilder: (context, index) {
                  final entry = sorted[index];
                  final jugador = entry.key;
                  final data = entry.value;

                  // Ícono según posición
                  String icon;
                  if (index == 0) {
                    icon = "👑";
                  } else if (index == 1) {
                    icon = "🥈";
                  } else if (index == 2) {
                    icon = "💩";
                  } else {
                    icon = "⚽";
                  }

                  final cardColor =
                      index == 0 ? const Color(0xFFD9F2E6) : Colors.white;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: index == 0
                          ? Border.all(color: const Color(0xFF006A36), width: 2)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(icon, style: const TextStyle(fontSize: 26)),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$jugador - ${data['nombre']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['club'],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${data['goles']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Color(0xFF006A36),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Asist: ${data['asistencias']} | PJ: ${data['partidos']}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Botón
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton.icon(
              onPressed: () async {
                await actualizarGoles();
              },
              icon: const Icon(Icons.refresh),
              label: const Text(
                'Actualizar goles',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006A36),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
