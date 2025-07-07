import 'package:flutter/material.dart';
import '../helpers/dio_client.dart';
import '../widgets/tiki_navbar.dart';

class RefugioPage extends StatefulWidget {
  const RefugioPage({super.key});

  @override
  State<RefugioPage> createState() => _RefugioPageState();
}

class _RefugioPageState extends State<RefugioPage> {
  Map<String, dynamic>? refugio;
  List<dynamic> mascotas = [];
  List<dynamic> solicitudes = [];
  String mensaje = '';
  bool cargando = true;

  final Color primaryColor = const Color(0xFFF4A484);
  final Color secondaryColor = const Color(0xFFE8926E);
  final Color backgroundColor = const Color(0xFFFFF8F5);

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      final authResponse = await DioClient.dio.get('/refugios/api/auth/check');
      final authData = authResponse.data;

      if (authData['isValid'] == true && authData['tipo'] == 'refugio') {
        final perfilResponse = await DioClient.dio.get('/refugios/api/perfil');
        if (!mounted) return;
        setState(() {
          refugio = perfilResponse.data['refugio'];
        });
        await cargarMascotas();
        await cargarSolicitudes();
      } else {
        if (!mounted) return;
        Future.microtask(() {
          Navigator.pushReplacementNamed(context, '/login');
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        mensaje = 'Error al cargar datos: \$e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        cargando = false;
      });
    }
  }

  Future<void> cargarMascotas() async {
    try {
      final response = await DioClient.dio.get('/refugios/mascotas');
      if (response.data['success'] == true && mounted) {
        setState(() {
          mascotas = response.data['mascotas'];
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        mensaje = 'Error al cargar mascotas: \$e';
      });
    }
  }

  Future<void> cargarSolicitudes() async {
    try {
      final response = await DioClient.dio.get(
        '/solicitudes/solicitudes',
        queryParameters: {'tipo': 'refugio', 'id': refugio?['idcentro']},
      );
      if (response.data['success'] == true && mounted) {
        setState(() {
          solicitudes = response.data['solicitudes'];
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        mensaje = 'Error al cargar solicitudes: \$e';
      });
    }
  }

  Future<void> actualizarEstadoSolicitud(int solicitudId, String nuevoEstado) async {
    try {
      final url = '/solicitudes/\$solicitudId/estado';
      final response = await DioClient.dio.post(
        url,
        data: {'estado': nuevoEstado},
      );

      if (response.data['success'] == true && mounted) {
        await cargarSolicitudes();
      } else {
        setState(() {
          mensaje = response.data['message'] ?? 'No se pudo actualizar el estado.';
        });
      }
    } catch (e) {
      setState(() {
        mensaje = 'Error al actualizar estado: \$e';
      });
    }
  }

  Future<void> logout() async {
    try {
      final response = await DioClient.dio.post('/refugios/logout');
      if (response.data['success'] == true && mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        mensaje = 'Error al cerrar sesión: \$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Panel del Refugio'),
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: refugio == null
          ? Center(child: Text(mensaje))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _seccionTitulo('📋 Datos del Refugio'),
                  _dato('Centro', refugio!['nombrecentro']),
                  _dato('Encargado', refugio!['nombreencargado']),
                  _dato('Correo', refugio!['correo']),
                  _dato('Teléfono', refugio!['telefono']),
                  _dato('Redes Sociales', refugio!['redesociales']),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _seccionTitulo('🐾 Mascotas Registradas'),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/registrarmascota'),
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                        child: const Text('Agregar Mascota'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (mascotas.isEmpty)
                    const Text('No hay mascotas registradas.')
                  else
                    ...mascotas.map((m) => _tarjetaMascota(m)),

                  const SizedBox(height: 30),

                  _seccionTitulo('📬 Solicitudes de Adopción'),
                  const SizedBox(height: 10),
                  if (solicitudes.isEmpty)
                    const Text('No hay solicitudes.')
                  else
                    ...solicitudes.map((s) => _tarjetaSolicitud(s)),

                  const SizedBox(height: 20),
                  if (mensaje.isNotEmpty)
                    Text(mensaje, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
      bottomNavigationBar: const TikiNavBar(selectedIndex: 4),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/about'),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _seccionTitulo(String texto) {
    return Text(
      texto,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: secondaryColor),
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
    final foto = m['foto']?.toString();
    final fotoUrl = (foto != null && foto.isNotEmpty)
        ? 'https://moviltika-production.up.railway.app/uploads/\$foto'
        : 'https://via.placeholder.com/80';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    fotoUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m['nombre'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${m['especie']} - ${m['genero']}'),
                      Text('${m['edad']} años'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/mascotainfo', arguments: m),
                style: ElevatedButton.styleFrom(backgroundColor: secondaryColor),
                child: const Text('Mostrar Mascota'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaSolicitud(dynamic s) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mascota: ${s['mascota_nombre']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Estado: ${s['estado']}'),
            Text('Fecha: ${s['fecha']?.substring(0, 10) ?? 'N/A'}'),
            const SizedBox(height: 8),
            if (s['estado'] == 'pendiente')
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => actualizarEstadoSolicitud(s['idsolicitud'], 'aceptado'),
                    icon: const Icon(Icons.check),
                    label: const Text('Aceptar'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => actualizarEstadoSolicitud(s['idsolicitud'], 'rechazado'),
                    icon: const Icon(Icons.close),
                    label: const Text('Rechazar'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
