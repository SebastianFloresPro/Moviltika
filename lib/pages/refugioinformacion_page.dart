import 'package:flutter/material.dart';
import '../helpers/dio_client.dart';
import 'package:url_launcher/url_launcher.dart';

class RefugioInformacionPage extends StatefulWidget {
  final Map<String, dynamic> refugio;

  const RefugioInformacionPage({super.key, required this.refugio});

  @override
  State<RefugioInformacionPage> createState() => _RefugioInformacionPageState();
}

class _RefugioInformacionPageState extends State<RefugioInformacionPage> {
  List<dynamic> mascotas = [];
  bool cargando = true;
  String mensaje = '';

  final Color baseColor = const Color(0xFFF2BA9D);
  final Color secondaryColor = const Color(0xFFEC8C68);
  final Color accentColor = const Color(0xFFF88064);

  @override
  void initState() {
    super.initState();
    cargarMascotas();
  }

  Future<void> cargarMascotas() async {
    try {
      final response =
          await DioClient.dio.get('/refugios/mascotas/${widget.refugio['idcentro']}');
      if (response.data['success'] == true) {
        setState(() {
          mascotas = response.data['mascotas'];
          cargando = false;
        });
      } else {
        setState(() {
          mensaje = 'No se pudieron cargar las mascotas';
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        mensaje = 'Error al cargar mascotas: $e';
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final refugio = widget.refugio;

    return Scaffold(
      backgroundColor: baseColor.withOpacity(0.05),
      appBar: AppBar(
        title: Text('Refugio: ${refugio['nombrecentro']}'),
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _seccionTitulo('🏠 Información del Refugio'),
                const SizedBox(height: 10),
                _dato('Encargado', refugio['nombreencargado']),
                _dato('Correo', refugio['correo']),
                _dato('Teléfono', refugio['telefono']),
                const SizedBox(height: 20),
                _seccionTitulo('🐾 Mascotas en este Refugio'),
                const SizedBox(height: 10),
                if (mensaje.isNotEmpty)
                  Text(mensaje, style: const TextStyle(color: Colors.red)),
                ...mascotas.map((m) => _tarjetaMascota(m)),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.home),
                  onPressed: () => Navigator.pop(context),
                  label: const Text('Volver a Refugios'),
                ),
                const SizedBox(height: 15),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: secondaryColor,
                    side: BorderSide(color: secondaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.web),
                  onPressed: () {
                    // Lanzar página web
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Abrir página web"),
                        content: const Text("¿Deseas visitar la página web del refugio?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Cancelar"),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              final uri = Uri.parse('https://tikapawdbp-48n3.onrender.com/');
                              if (!await launchUrl(uri)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("No se pudo abrir el navegador")),
                                );
                              }
                            },
                            child: const Text("Visitar sitio"),
                          ),
                        ],
                      ),
                    );
                  },
                  label: const Text('Conoce nuestra página web'),
                ),
              ],
            ),
    );
  }

  Widget _seccionTitulo(String texto) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: secondaryColor,
      ),
    );
  }

  Widget _dato(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }

  Widget _tarjetaMascota(dynamic m) {
    final fotoUrl = m['foto'] != null
        ? 'https://moviltika-production.up.railway.app/uploads/${m['foto']}'
        : null;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: fotoUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  fotoUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.pets, size: 40),
        title: Text(m['nombre'] ?? 'Sin nombre'),
        subtitle: Text('${m['especie']} - ${m['edad']} años'),
        onTap: () => Navigator.pushNamed(
          context,
          '/mascotainfosolicitud',
          arguments: m,
        ),
      ),
    );
  }
}
