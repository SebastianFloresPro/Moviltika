import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../helpers/dio_client.dart';

class MascotaInfoPage extends StatefulWidget {
  final Map<String, dynamic> mascota;

  const MascotaInfoPage({super.key, required this.mascota});

  @override
  State<MascotaInfoPage> createState() => _MascotaInfoPageState();
}

class _MascotaInfoPageState extends State<MascotaInfoPage> {
  List<dynamic> solicitudes = [];
  String mensaje = '';
  bool cargando = true;

  final Color coral = const Color(0xFFF4A484);
  final Color coralDark = const Color(0xFFE8926E);
  final Color fondoSuave = const Color(0xFFFFF8F5);

  @override
  void initState() {
    super.initState();
    cargarSolicitudes();
  }

  Future<void> cargarSolicitudes() async {
    try {
      final response = await DioClient.dio.get(
        '/solicitudes/mascota/${widget.mascota['idmascota']}',
        options: Options(validateStatus: (status) => status != null && status < 500),
      );

      if (!mounted) return;

      if (response.statusCode == 404) {
        setState(() => solicitudes = []);
      } else if (response.data['success'] == true) {
        setState(() => solicitudes = response.data['solicitudes']);
      } else {
        setState(() => mensaje = response.data['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => mensaje = 'Error al cargar solicitudes: $e');
    } finally {
      if (!mounted) return;
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.mascota;

    final fotoUrl = m['foto'] != null && m['foto'].toString().isNotEmpty
        ? 'https://moviltika-production.up.railway.app/uploads/${m['foto']}'
        : 'https://via.placeholder.com/200';

    return Scaffold(
      backgroundColor: fondoSuave,
      appBar: AppBar(
        title: Text('Mascota: ${m['nombre']}'),
        backgroundColor: coral,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  fotoUrl,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _infoRow('Nombre', m['nombre']),
            _infoRow('Edad', '${m['edad']} años'),
            _infoRow('Especie', m['especie']),
            _infoRow('Género', m['genero']),
            _infoRow('Tamaño', m['tamanio']),
            const SizedBox(height: 12),
            const Text(
              'Descripción:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              m['descripcion'] ?? '-',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            const Text(
              'Solicitudes de Adopción',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (cargando)
              const Center(child: CircularProgressIndicator())
            else if (solicitudes.isEmpty)
              const Text('No hay solicitudes registradas.')
            else
              ...solicitudes.map((s) => Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.person, color: coralDark),
                      title: Text('Estado: ${s['estado']}'),
                      subtitle: Text('Fecha: ${s['fecha']?.substring(0, 10) ?? 'N/A'}'),
                    ),
                  )),
            if (mensaje.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  mensaje,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/refugio');
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver al perfil del refugio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: coralDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
      ),
    );
  }
}
