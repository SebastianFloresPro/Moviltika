import 'package:flutter/material.dart';
import '../helpers/dio_client.dart';
import '../widgets/tiki_navbar.dart';
import 'refugioinformacion_page.dart';

class RefugiosPage extends StatefulWidget {
  const RefugiosPage({super.key});

  @override
  State<RefugiosPage> createState() => _RefugiosPageState();
}

class _RefugiosPageState extends State<RefugiosPage> {
  List<dynamic> refugios = [];
  bool cargando = true;
  String mensaje = '';

  final Color baseColor = const Color(0xFFF2BA9D); // 60%
  final Color secondaryColor = const Color(0xFFEC8C68); // 20%
  final Color accentColor = const Color(0xFFF88064); // 10%

  @override
  void initState() {
    super.initState();
    cargarRefugios();
  }

  Future<void> cargarRefugios() async {
    try {
      final response = await DioClient.dio.get('/refugios/refugios');
      if (response.data['success'] == true && mounted) {
        setState(() {
          refugios = response.data['refugios'];
        });
      } else {
        setState(() {
          mensaje = 'No se pudieron cargar los refugios.';
        });
      }
    } catch (e) {
      setState(() {
        mensaje = 'Error al cargar refugios: $e';
      });
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: baseColor.withOpacity(0.1),
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: const Text('Refugios'),
        centerTitle: true,
        elevation: 4,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : refugios.isEmpty
              ? Center(
                  child: Text(
                    mensaje.isNotEmpty ? mensaje : 'No hay refugios disponibles.',
                    style: TextStyle(color: Colors.grey[700], fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: refugios.length,
                  itemBuilder: (context, index) {
                    final refugio = refugios[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          refugio['nombrecentro'] ?? 'Sin nombre',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Encargado: ${refugio['nombreencargado'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RefugioInformacionPage(refugio: refugio),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Ver'),
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: const TikiNavBar(selectedIndex: 1),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/about');
        },
        backgroundColor: secondaryColor,
        child: const Icon(Icons.info_outline),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
