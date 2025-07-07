import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/tiki_navbar.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  void _abrirSitioWeb() async {
    const url = 'https://tikapawdbp-48n3.onrender.com/';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFFF4A484); // Color principal pastel salmón
    const Color bgColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Sobre TikaPaw'),
        backgroundColor: accentColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              '🐾 TikaPaw',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'TikaPaw es una plataforma dedicada a conectar personas con refugios de animales para fomentar la adopción responsable.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 30),
            const Text(
              '🌎 Nuestra Misión',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            const Text(
              'Dar visibilidad a refugios y mascotas que buscan un hogar, promoviendo el bienestar animal.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            const Text(
              '🤝 Colabora con Nosotros',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            const Text(
              'Si tienes un refugio o quieres ayudar, únete a nuestra comunidad y haz la diferencia.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _abrirSitioWeb,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.link, color: Colors.white),
              label: const Text(
                'Visita nuestro sitio web',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  const Text(
                    'TikaPaw - Adopta con el corazón 🐶🐱',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://moviltika-production.up.railway.app/uploads/logo.png',
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const TikiNavBar(selectedIndex: -1),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirSitioWeb,
        backgroundColor: accentColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
