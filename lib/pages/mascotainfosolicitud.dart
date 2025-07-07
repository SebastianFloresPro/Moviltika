import 'package:flutter/material.dart';
import '../helpers/dio_client.dart';
import 'solicitudes_page.dart';

class MascotaInfoSolicitudPage extends StatelessWidget {
  final Map<String, dynamic> mascota;

  const MascotaInfoSolicitudPage({super.key, required this.mascota});

  Future<void> irAlFormulario(BuildContext context) async {
    try {
      final res = await DioClient.dio.get('/usuarios/api/auth/check');
      final data = res.data;

      final isOk = data['isValid'] == true || data['success'] == true;
      final esUsuario = data['tipo'] == 'usuario';

      if (isOk && esUsuario) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SolicitudFormularioPage(mascota: mascota),
          ),
        );
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color coral = Color(0xFFF4A484);
    const Color coralDark = Color(0xFFE8926E);
    const Color fondoSuave = Color(0xFFFFF8F5);

    return Scaffold(
      backgroundColor: fondoSuave,
      appBar: AppBar(
        title: Text('Mascota: ${mascota['nombre']}'),
        backgroundColor: coral,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  mascota['foto'] != null && mascota['foto'].toString().isNotEmpty
                      ? 'https://moviltika-production.up.railway.app/uploads/${mascota['foto']}'
                      : 'https://via.placeholder.com/200',
                  width: 220,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: coral.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoLine('Nombre', mascota['nombre']),
                  _infoLine('Edad', '${mascota['edad']} años'),
                  _infoLine('Especie', mascota['especie']),
                  _infoLine('Género', mascota['genero']),
                  _infoLine('Tamaño', mascota['tamanio']),
                  const SizedBox(height: 10),
                  const Text(
                    'Descripción:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    mascota['descripcion'] ?? '-',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => irAlFormulario(context),
                icon: const Icon(Icons.pets),
                label: const Text('Solicitar Adopción'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: coralDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Volver',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
