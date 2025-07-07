import 'package:flutter/material.dart';
import '../helpers/dio_client.dart';
import '../widgets/tiki_navbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String mensaje = '';
  bool cargando = false;

  final Color coral = const Color(0xFFF4A484);
  final Color coralDark = const Color(0xFFE8926E);
  final Color fondoSuave = const Color(0xFFFFF8F5);

  Future<void> login() async {
    FocusScope.of(context).unfocus();
    setState(() {
      cargando = true;
      mensaje = '';
    });

    try {
      final response = await DioClient.dio.post(
        '/usuarios/login',
        data: {
          'correo': correoController.text.trim(),
          'password': passwordController.text.trim(),
        },
      );

      final body = response.data;

      if (response.statusCode == 200 && body['success'] == true) {
        Navigator.pushReplacementNamed(context, '/usuario');
      } else {
        setState(() {
          mensaje = '❌ ${body['message'] ?? 'No se pudo iniciar sesión'}';
        });
      }
    } catch (e) {
      setState(() {
        mensaje = '⚠️ Error de red: $e';
      });
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondoSuave,
      appBar: AppBar(
        title: const Text('Iniciar Sesión - TikiTiki'),
        backgroundColor: coral,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Icon(Icons.pets, size: 80, color: coralDark),
            const SizedBox(height: 10),
            Text(
              'Bienvenido a TikiTiki 🐾',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: correoController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            cargando
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: login,
                    icon: const Icon(Icons.login),
                    label: const Text('Iniciar Sesión'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: coralDark,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/crearcuenta'),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Crear Cuenta de Usuario'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(45),
                side: BorderSide(color: coralDark),
                foregroundColor: coralDark,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/registrarrefugio'),
              icon: const Icon(Icons.home_work_outlined),
              label: const Text('Registrar Refugio'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(45),
                side: BorderSide(color: coralDark),
                foregroundColor: coralDark,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/loginrefugio'),
              icon: Icon(Icons.account_circle_outlined, color: coralDark),
              label: Text('Login como Refugio', style: TextStyle(color: coralDark)),
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
      bottomNavigationBar: const TikiNavBar(selectedIndex: 4),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/about'),
        backgroundColor: coral,
        
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
