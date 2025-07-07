import 'package:flutter/material.dart';
import '../helpers/dio_client.dart';
import '../widgets/tiki_navbar.dart';

class BuscarPage extends StatefulWidget {
  const BuscarPage({super.key});

  @override
  State<BuscarPage> createState() => _BuscarPageState();
}

class _BuscarPageState extends State<BuscarPage> {
  final TextEditingController _busquedaController = TextEditingController();
  List<dynamic> resultados = [];
  bool cargando = false;
  String? error;

  // Colores personalizados
  final Color coral = const Color(0xFFF4A484);
  final Color coralDark = const Color(0xFFE8926E);
  final Color softBackground = const Color(0xFFFFF8F5);

  Future<void> _buscar() async {
    final termino = _busquedaController.text.trim();
    if (termino.isEmpty) {
      setState(() {
        error = 'Debe escribir un término para buscar.';
        resultados = [];
      });
      return;
    }

    setState(() {
      cargando = true;
      resultados = [];
      error = null;
    });

    try {
      final response = await DioClient.dio.get(
        '/busqueda/mascotas/${Uri.encodeComponent(termino)}',
      );

      final data = response.data;
      print('📥 Backend respondió: $data');

      if (data['success'] == true && data['mascotas'] != null) {
        setState(() {
          resultados = data['mascotas'];
          if (resultados.isEmpty) {
            error = 'No se encontraron mascotas con ese término.';
          }
        });
      } else {
        setState(() {
          error = data['message'] ?? 'No se encontraron resultados.';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error buscando mascotas. Revisa tu conexión.';
      });
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  void _abrirDetalle(Map<String, dynamic> mascota) {
    Navigator.pushNamed(context, '/mascotainfosolicitud', arguments: mascota);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBackground,
      appBar: AppBar(
        title: const Text('Buscar en TikaPaw'),
        backgroundColor: coral,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _busquedaController,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o especie...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: coralDark),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send, color: coralDark),
                    onPressed: _buscar,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (cargando)
              const CircularProgressIndicator()
            else if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red))
            else if (resultados.isEmpty)
              const Text('No hay resultados todavía. Intenta buscar algo.')
            else
              Expanded(
                child: ListView.separated(
                  itemCount: resultados.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final m = resultados[index];
                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            m['foto'] != null && m['foto'].toString().isNotEmpty
                                ? 'https://moviltika-production.up.railway.app/uploads/${m['foto']}'
                                : 'https://via.placeholder.com/100x100.png?text=🐾',
                          ),
                          radius: 28,
                        ),
                        title: Text(
                          m['nombre'] ?? 'Sin nombre',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${m['especie']} - ${m['nombrecentro']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: Icon(Icons.pets, color: coralDark),
                        onTap: () => _abrirDetalle(m),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const TikiNavBar(selectedIndex: 3),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/about'),
        backgroundColor: coral,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
