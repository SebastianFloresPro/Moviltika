import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../helpers/dio_client.dart';

class AgregarMascotaPage extends StatefulWidget {
  const AgregarMascotaPage({super.key});

  @override
  State<AgregarMascotaPage> createState() => _AgregarMascotaPageState();
}

class _AgregarMascotaPageState extends State<AgregarMascotaPage> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final especieController = TextEditingController();
  final edadController = TextEditingController();
  final descripcionController = TextEditingController();

  String? genero;
  String? tamanio;
  File? imagen;
  String mensaje = '';
  bool cargando = false;

  final tamanios = ['pequeño', 'mediano', 'grande'];
  final generos = ['macho', 'hembra'];

  Future<void> seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagen = File(pickedFile.path);
      });
    }
  }

  Future<void> enviarFormulario() async {
    if (!_formKey.currentState!.validate() || imagen == null) {
      setState(() {
        mensaje = 'Completa todos los campos y selecciona una imagen';
      });
      return;
    }

    setState(() {
      cargando = true;
      mensaje = '';
    });

    try {
      final authResponse = await DioClient.dio.get('/refugios/api/auth/check');
      final tipo = authResponse.data['tipo'];
      final idcentro = authResponse.data['userId'];

      if (authResponse.data['isValid'] != true || tipo != 'refugio') {
        setState(() => mensaje = 'Sesión no válida');
        return;
      }

      final formData = FormData.fromMap({
        'nombre': nombreController.text,
        'tamanio': tamanio,
        'especie': especieController.text,
        'edad': edadController.text,
        'genero': genero,
        'descripcion': descripcionController.text,
        'idcentro': idcentro,
        'foto': await MultipartFile.fromFile(imagen!.path, filename: 'mascota.jpg'),
      });

      final response = await DioClient.dio.post('/refugios/mascotas/register', data: formData);

      if (response.data['success'] == true) {
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/refugio');
          }
        });
      } else {
        setState(() => mensaje = response.data['message'] ?? 'Error al registrar mascota');
      }
    } catch (e) {
      setState(() => mensaje = 'Error al enviar: $e');
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F2),
      appBar: AppBar(
        title: const Text('Agregar Mascota'),
        backgroundColor: const Color(0xFFF4A484),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(nombreController, 'Nombre'),
                    _buildTextField(especieController, 'Especie'),
                    const SizedBox(height: 10),
                    _buildDropdown('Tamaño', tamanios, tamanio, (value) => setState(() => tamanio = value)),
                    const SizedBox(height: 10),
                    _buildTextField(edadController, 'Edad',
                        inputType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo requerido';
                          if (int.tryParse(v) == null) return 'Debe ser un número';
                          return null;
                        }),
                    const SizedBox(height: 10),
                    _buildDropdown('Género', generos, genero, (value) => setState(() => genero = value)),
                    const SizedBox(height: 10),
                    _buildTextField(descripcionController, 'Descripción', maxLines: 3),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: seleccionarImagen,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF4A484),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      ),
                      icon: const Icon(Icons.image),
                      label: const Text('Seleccionar Foto'),
                    ),
                    if (imagen != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(imagen!, width: 150, height: 150, fit: BoxFit.cover),
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: enviarFormulario,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF4A484),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                      ),
                      child: const Text('Registrar Mascota'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            Navigator.pushReplacementNamed(context, '/refugio');
                          }
                        });
                      },
                      child: const Text('Volver al Panel del Refugio'),
                    ),
                    const SizedBox(height: 10),
                    if (mensaje.isNotEmpty)
                      Text(
                        mensaje,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1, TextInputType inputType = TextInputType.text, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: inputType,
      validator: validator ?? (value) => value!.isEmpty ? 'Campo requerido' : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDropdown(
      String label, List<String> items, String? value, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: items.map((op) => DropdownMenuItem(value: op, child: Text(op))).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Selecciona una opción' : null,
    );
  }
}
