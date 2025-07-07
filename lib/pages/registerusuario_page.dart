import 'package:flutter/material.dart';
import '../helpers/dio_client.dart';

class RegistrarUsuarioPage extends StatefulWidget {
  const RegistrarUsuarioPage({super.key});

  @override
  State<RegistrarUsuarioPage> createState() => _RegistrarUsuarioPageState();
}

class _RegistrarUsuarioPageState extends State<RegistrarUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final edadController = TextEditingController();
  final correoController = TextEditingController();
  final telefonoController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmarPasswordController = TextEditingController();

  String mensaje = '';
  bool cargando = false;

  final Color baseColor = const Color(0xFFF2BA9D); // 60%
  final Color secondaryColor = const Color(0xFFEC8C68); // 20%
  final Color accentColor = const Color(0xFFF88064); // 10%

  Future<void> registrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      mensaje = '';
      cargando = true;
    });

    final data = {
      'nombre': nombreController.text.trim(),
      'edad': edadController.text.trim(),
      'correo': correoController.text.trim(),
      'telefono': telefonoController.text.trim(),
      'password': passwordController.text.trim(),
    };

    try {
      final response = await DioClient.dio.post('/usuarios/register', data: data);
      if (response.data['success'] == true) {
        setState(() => mensaje = '✅ Registro exitoso');
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() => mensaje = response.data['message'] ?? '❌ Error desconocido');
      }
    } catch (e) {
      setState(() => mensaje = '⚠️ Error al registrar: $e');
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    edadController.dispose();
    correoController.dispose();
    telefonoController.dispose();
    passwordController.dispose();
    confirmarPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: baseColor.withOpacity(0.15),
      appBar: AppBar(
        title: const Text('Registro de Usuario'),
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text('Crea tu cuenta', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: nombreController,
                          label: 'Nombre',
                          keyboardType: TextInputType.name,
                          validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
                        ),
                        _buildTextField(
                          controller: edadController,
                          label: 'Edad',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Campo requerido';
                            if (int.tryParse(value) == null) return 'Edad inválida';
                            return null;
                          },
                        ),
                        _buildTextField(
                          controller: correoController,
                          label: 'Correo electrónico',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Campo requerido';
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Correo inválido';
                            return null;
                          },
                        ),
                        _buildTextField(
                          controller: telefonoController,
                          label: 'Teléfono',
                          keyboardType: TextInputType.phone,
                          validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
                        ),
                        _buildTextField(
                          controller: passwordController,
                          label: 'Contraseña',
                          obscureText: true,
                          validator: (value) => value == null || value.length < 6 ? 'Mínimo 6 caracteres' : null,
                        ),
                        _buildTextField(
                          controller: confirmarPasswordController,
                          label: 'Confirmar Contraseña',
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Campo requerido';
                            if (value != passwordController.text) return 'Las contraseñas no coinciden';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: registrarUsuario,
                          icon: const Icon(Icons.person_add),
                          label: const Text('Registrarse'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                        ),
                        if (mensaje.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              mensaje,
                              style: TextStyle(
                                color: mensaje.startsWith('✅') ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: baseColor.withOpacity(0.05),
        ),
      ),
    );
  }
}
