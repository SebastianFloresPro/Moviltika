import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class RegistrarRefugioPage extends StatefulWidget {
  const RegistrarRefugioPage({super.key});

  @override
  State<RegistrarRefugioPage> createState() => _RegistrarRefugioPageState();
}

class _RegistrarRefugioPageState extends State<RegistrarRefugioPage> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  final nombreEncargadoController = TextEditingController();
  final nombreCentroController = TextEditingController();
  final telefonoController = TextEditingController();
  final correoController = TextEditingController();
  final redesController = TextEditingController();
  final contrasenaController = TextEditingController();

  File? logoImage;
  File? portadaImage;

  bool _cargando = false;
  String _mensaje = '';

  final primaryColor = const Color(0xFFF2BA9D); // 60%
  final secondaryColor = const Color(0xFFEC8C68); // 20%
  final accentColor = const Color(0xFFF88064); // 10%

  Future<void> _pickImage(bool isLogo) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isLogo) {
          logoImage = File(picked.path);
        } else {
          portadaImage = File(picked.path);
        }
      });
    }
  }

  Future<void> _registrarRefugio() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _mensaje = '';
      _cargando = true;
    });

    try {
      final formData = FormData.fromMap({
        'nombreencargado': nombreEncargadoController.text,
        'nombrecentro': nombreCentroController.text,
        'telefono': telefonoController.text,
        'correo': correoController.text,
        'redesociales': redesController.text,
        'contrasena': contrasenaController.text,
        if (logoImage != null)
          'logo': await MultipartFile.fromFile(logoImage!.path, filename: 'logo.jpg'),
        if (portadaImage != null)
          'portada': await MultipartFile.fromFile(portadaImage!.path, filename: 'portada.jpg'),
      });

      final dio = Dio();
      final response = await dio.post(
        'https://moviltika-production.up.railway.app/refugios/registerrefugio',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.data['success'] == true) {
        setState(() => _mensaje = '🎉 Refugio registrado correctamente.');
      } else {
        setState(() => _mensaje = '❌ Error: ${response.data['message'] ?? "Desconocido"}');
      }
    } catch (e) {
      setState(() => _mensaje = '❗ Error: $e');
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Refugio'),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text('Crear Refugio',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: secondaryColor)),

              const SizedBox(height: 20),
              _buildTextField(nombreEncargadoController, 'Nombre del encargado'),
              _buildTextField(nombreCentroController, 'Nombre del centro'),
              _buildTextField(telefonoController, 'Teléfono'),
              _buildTextField(correoController, 'Correo electrónico', keyboardType: TextInputType.emailAddress),
              _buildTextField(redesController, 'Redes sociales'),
              _buildTextField(contrasenaController, 'Contraseña', obscure: true),

              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => _pickImage(true),
                icon: const Icon(Icons.image),
                label: Text(logoImage == null ? 'Seleccionar Logo' : 'Logo seleccionado ✅'),
                style: OutlinedButton.styleFrom(foregroundColor: accentColor),
              ),
              OutlinedButton.icon(
                onPressed: () => _pickImage(false),
                icon: const Icon(Icons.image),
                label: Text(portadaImage == null ? 'Seleccionar Portada' : 'Portada seleccionada ✅'),
                style: OutlinedButton.styleFrom(foregroundColor: accentColor),
              ),

              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _cargando ? null : _registrarRefugio,
                icon: const Icon(Icons.save),
                label: _cargando
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
                    : const Text('Registrar Refugio'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: secondaryColor),
              ),

              const SizedBox(height: 20),
              if (_mensaje.isNotEmpty)
                Text(
                  _mensaje,
                  style: TextStyle(
                    color: _mensaje.startsWith('🎉') ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 30),
              const Divider(),
              const Text('¿Ya tienes cuenta o deseas crear una?'),

              const SizedBox(height: 10),
              FilledButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: FilledButton.styleFrom(backgroundColor: primaryColor),
                child: const Text('Iniciar sesión (Usuario)'),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () => Navigator.pushNamed(context, '/loginrefugio'),
                style: FilledButton.styleFrom(backgroundColor: primaryColor),
                child: const Text('Iniciar sesión (Refugio)'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/registerusuario'),
                style: OutlinedButton.styleFrom(foregroundColor: secondaryColor),
                child: const Text('Crear cuenta de Usuario'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text, bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(color: Colors.brown[700]),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
      ),
    );
  }
}
