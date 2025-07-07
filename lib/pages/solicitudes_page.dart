import 'package:flutter/material.dart';
import '../helpers/dio_client.dart';

class SolicitudFormularioPage extends StatefulWidget {
  final Map<String, dynamic>? mascota;

  const SolicitudFormularioPage({super.key, this.mascota});

  @override
  State<SolicitudFormularioPage> createState() => _SolicitudFormularioPageState();
}

class _SolicitudFormularioPageState extends State<SolicitudFormularioPage> {
  List<dynamic> mascotas = [];
  int? selectedMascotaId;
  String motivo = '';
  String experiencia = '';
  String mensaje = '';
  bool cargando = true;

  final Color baseColor = const Color(0xFFF2BA9D); // 60%
  final Color secondaryColor = const Color(0xFFEC8C68); // 20%
  final Color accentColor = const Color(0xFFF88064); // 10%

  @override
  void initState() {
    super.initState();
    cargarMascotas();
  }

  Future<void> cargarMascotas() async {
    try {
      final res = await DioClient.dio.get('/mascotas');
      if (res.data['success'] == true) {
        setState(() {
          mascotas = res.data['mascotas'];
          cargando = false;
          if (widget.mascota != null) {
            selectedMascotaId = widget.mascota!['idmascota'];
          }
        });
      } else {
        setState(() {
          mensaje = 'Error al cargar mascotas.';
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        mensaje = 'Error de conexión al cargar.';
        cargando = false;
      });
    }
  }

  void enviarSolicitud() async {
    if (selectedMascotaId == null || motivo.isEmpty || experiencia.isEmpty) {
      setState(() {
        mensaje = 'Por favor, completa todos los campos.';
      });
      return;
    }

    try {
      final res = await DioClient.dio.post(
        '/mascotas/solicitar-adopcion',
        data: {
          'mascotaId': selectedMascotaId,
          'motivo': motivo,
          'experiencia': experiencia,
        },
      );
      if (res.data['success'] == true) {
        setState(() {
          mensaje = '✅ Solicitud enviada con éxito.';
          motivo = '';
          experiencia = '';
          selectedMascotaId = null;
        });
      } else {
        setState(() {
          mensaje = 'Error al enviar solicitud.';
        });
      }
    } catch (e) {
      setState(() {
        mensaje = 'Error de conexión al enviar.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: baseColor.withOpacity(0.1),
      appBar: AppBar(
        title: const Text('Solicitud de Adopción'),
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    children: [
                      DropdownButtonFormField<int>(
                        value: selectedMascotaId,
                        decoration: InputDecoration(
                          labelText: 'Selecciona una mascota',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        isExpanded: true,
                        items: mascotas.map<DropdownMenuItem<int>>((mascota) {
                          return DropdownMenuItem<int>(
                            value: mascota['idmascota'],
                            child: Text('${mascota['nombre']} (${mascota['especie']})'),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          setState(() => selectedMascotaId = newValue);
                        },
                      ),
                      const SizedBox(height: 16),
                      if (selectedMascotaId != null) ..._buildMascotaInfo(),
                      const SizedBox(height: 16),
                      _buildTextArea(
                        label: 'Motivo de adopción',
                        onChanged: (val) => motivo = val,
                      ),
                      const SizedBox(height: 16),
                      _buildTextArea(
                        label: 'Experiencia con mascotas',
                        onChanged: (val) => experiencia = val,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: enviarSolicitud,
                        icon: const Icon(Icons.send),
                        label: const Text('Enviar Solicitud'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (mensaje.isNotEmpty)
                        Text(
                          mensaje,
                          style: TextStyle(
                            color: mensaje.startsWith('✅') ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextArea({required String label, required Function(String) onChanged}) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: baseColor.withOpacity(0.05),
      ),
      maxLines: 3,
      onChanged: onChanged,
    );
  }

  List<Widget> _buildMascotaInfo() {
    final mascota = mascotas.firstWhere(
      (m) => m['idmascota'] == selectedMascotaId,
      orElse: () => null,
    );

    if (mascota == null) return [];

    final fotoUrl = mascota['foto'] != null
        ? (mascota['foto'].toString().startsWith('/uploads/')
            ? 'https://moviltika-production.up.railway.app${mascota['foto']}'
            : 'https://moviltika-production.up.railway.app/uploads/${mascota['foto']}')
        : null;

    return [
      const SizedBox(height: 12),
      if (fotoUrl != null)
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            fotoUrl,
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
      const SizedBox(height: 8),
      Text('Edad: ${mascota['edad'] ?? '-'} años', style: const TextStyle(fontWeight: FontWeight.w500)),
      Text('Descripción: ${mascota['descripcion'] ?? 'Sin descripción'}'),
    ];
  }
}
