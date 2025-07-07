import 'package:flutter/material.dart';
import '../helpers/dio_client.dart';

class LoginRefugioPage extends StatefulWidget {
  const LoginRefugioPage({super.key});

  @override
  State<LoginRefugioPage> createState() => _LoginRefugioPageState();
}

class _LoginRefugioPageState extends State<LoginRefugioPage> {
  final _formKey = GlobalKey<FormState>();
  final correoController = TextEditingController();
  final passwordController = TextEditingController();

  String mensaje = '';
  bool cargando = false;

  final Color coral = const Color(0xFFF4A484);
  final Color coralDark = const Color(0xFFE8926E);
  final Color fondoSuave = const Color(0xFFFFF8F5);

  Future<void> loginRefugio() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      mensaje = '';
      cargando = true;
    });

    final data = {
      'correo': correoController.text.trim(),
      'password': passwordController.text.trim(),
    };

    try {
      final response = await DioClient.dio.post('/refugios/login', data: data);

      if (response.data['success'] == true) {
        setState(() => mensaje = '✅ Inicio de sesión exitoso');
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pushReplacementNamed(context, '/refugio');
      } else {
        setState(() => mensaje = response.data['message'] ?? '❌ Credenciales inválidas');
      }
    } catch (e) {
      setState(() => mensaje = '⚠️ Error de red: $e');
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondoSuave,
      appBar: AppBar(
        title: const Text('Login Refugio'),
        backgroundColor: coral,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Icon(Icons.home_work_rounded, size: 80, color: coralDark),
                    const SizedBox(height: 20),
                    const Text(
                      'Iniciar Sesión como Refugio',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: correoController,
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Campo requerido';
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return 'Correo inválido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            obscureText: true,
                            validator: (value) =>
                                value == null || value.length < 6 ? 'Mínimo 6 caracteres' : null,
                          ),
                          const SizedBox(height: 25),
                          ElevatedButton.icon(
                            onPressed: loginRefugio,
                            icon: const Icon(Icons.login),
                            label: const Text('Iniciar sesión'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: coralDark,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 15),
                          OutlinedButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/registrarrefugio'),
                            child: const Text('¿No tienes cuenta? Regístrate'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: coralDark),
                              foregroundColor: coralDark,
                              minimumSize: const Size.fromHeight(45),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                            child: Text('Iniciar sesión como Usuario', style: TextStyle(color: coralDark)),
                          ),
                          const SizedBox(height: 20),
                          if (mensaje.isNotEmpty)
                            Text(
                              mensaje,
                              style: TextStyle(
                                color: mensaje.startsWith('✅') ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
