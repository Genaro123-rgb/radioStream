import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:radio_app/radio/radio.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  RadioClass radioClass = RadioClass();
  bool isPlaying = false;
  String? currentlyPlayingUrl; // Variable para rastrear la estación actualmente reproduciéndose

  // Función para abrir una página web con try-catch detallado
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri)) {
        throw 'No se pudo abrir $url. Verifica la URL o la configuración del dispositivo.';
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  // Muestra un mensaje de conexión
  Future<void> _showConnecting() async {
    Fluttertoast.showToast(
      msg: "Connecting...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
    await Future.delayed(const Duration(seconds: 1));
  }

  // Función para reproducir la radio y mostrar el mensaje "Connecting..."
  Future<void> _playRadio(String imgURL, String radioStation, String streamURL) async {
    try {
      if (currentlyPlayingUrl == streamURL && isPlaying) {
        // Si ya se está reproduciendo la misma estación, se detiene
        _stopRadio();
      } else {
        await _showConnecting();

        // Si ya hay otra estación reproduciéndose, la detiene
        if (currentlyPlayingUrl != null && currentlyPlayingUrl != streamURL) {
          _stopRadio();
        }

        // Actualiza la URL actualmente reproduciéndose
        currentlyPlayingUrl = streamURL;
        await radioClass.setChannel({
          'imageAsset': imgURL,
          'name': radioStation,
          'streamURL': streamURL,
        });

        // Inicia la reproducción
        radioClass.play();
        setState(() {
          isPlaying = true;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error al conectar a la estación: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  // Función para detener la radio
  void _stopRadio() {
    try {
      radioClass.stop();
      setState(() {
        isPlaying = false;
        //currentlyPlayingUrl = null; // Limpia la estación que estaba reproduciéndose
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error al detener la estación: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  // Función para manejar la apertura de YouTube
  Future<void> _openYouTube(String url) async {
    try {
      final Uri youtubeUri = Uri.parse(url);
      if (await canLaunchUrl(youtubeUri)) {
        await launchUrl(youtubeUri, mode: LaunchMode.externalApplication);
      } else {
        await _launchURL(url);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "No se pudo abrir YouTube: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  @override
  void dispose() {
    try {
      radioClass.stop();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error al detener la estación: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
    super.dispose();
  }

  // Nueva función para pausar o reanudar la estación actual
  void _toggleRadio() {
    if (isPlaying) {
      _stopRadio();  // Si está reproduciendo, detener
    } else if (currentlyPlayingUrl != null) {
      // Si no está reproduciendo pero hay una estación seleccionada, reanudar
      // Fluttertoast.showToast(
      //   msg: "Reanudando la estación...",
      //   toastLength: Toast.LENGTH_SHORT,
      //   gravity: ToastGravity.CENTER,
      // );
      radioClass.play();
      setState(() {
        isPlaying = true;
      });
    } else {
      Fluttertoast.showToast(
        msg: "No hay ninguna estación seleccionada para reproducir.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Radio Del Rio",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: 'TypeWriter'
          ),
        ),
        actions: [
          IconButton(
            icon: const Text(
              "ⓘ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: 'TypeWriter'
              ),
            ),
            onPressed: () => _launchURL('https://sites.google.com/view/rgroupstream/p%C3%A1gina-principal'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildButton(
              'assets/images/KDRX.jpeg',
              () => _playRadio('assets/images/KDRX.jpeg', 'KDRX 106.9 FM', 'https://s01.digitalserver.org:8106/stream'),
            ),
          ),
          Expanded(
            child: _buildButton(
              'assets/images/KTDR.jpeg',
              () => _playRadio('assets/images/KTDR.jpeg', 'KTDR 96.3 FM', 'https://s01.digitalserver.org/8038/stream'),
            ),
          ),
          Expanded(
            child: _buildButton(
              'assets/images/KVDR.jpeg',
              () => _playRadio('assets/images/KVDR.jpeg', 'KVDR 94.7 FM', 'https://s01.digitalserver.org:8142/stream'),
            ),
          ),
          Expanded(
            child: _buildButton(
              'assets/images/Live.jpg',
              () => _openYouTube('https://www.youtube.com/@ktdrlivecam7796'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleRadio,  // Llamada a la función para pausar/reanudar
        backgroundColor: Colors.black,
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,  // Cambia el icono según el estado
          color: Colors.white,
        ),
      ),
    );
  }

  // Función que crea un botón con una imagen de fondo y una acción de clic
  Widget _buildButton(String imagePath, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(0), // Espaciado entre botones
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: Colors.transparent, // Color del texto
          padding: EdgeInsets.zero, // Sin padding
        ),
        onPressed: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}
