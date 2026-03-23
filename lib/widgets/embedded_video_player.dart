import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:criterium/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:visibility_detector/visibility_detector.dart';

// =======================================================
// 1. EL REPRODUCTOR DEL FEED (Vista Previa Silenciosa)
// =======================================================
class EmbeddedVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;

  const EmbeddedVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<EmbeddedVideoPlayer> createState() => _EmbeddedVideoPlayerState();
}

class _EmbeddedVideoPlayerState extends State<EmbeddedVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void didUpdateWidget(covariant EmbeddedVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeController();
      setState(() {}); 
    }
  }

  void _initController() async {
    if (_controller != null) return;

    String finalUrl = widget.videoUrl;
    String currentBaseUrl = dotenv.env['API_URL'] ?? '';

    // Traductor de URL
    if (currentBaseUrl.isNotEmpty && finalUrl.contains('/uploads/')) {
      String serverHost = currentBaseUrl.replaceAll('/api', ''); 
      String fileName = finalUrl.split('/uploads/').last;
      finalUrl = '$serverHost/uploads/$fileName';
    }
    
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(finalUrl),
      httpHeaders: {'ngrok-skip-browser-warning': 'true'},
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        _controller!.setVolume(0.0); // 🔇 Siempre en silencio en el feed
        _controller!.setLooping(true); // 🔄 Se repite
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
        _controller!.play(); // Inicia la vista previa
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 EL MAGO: Controla que no explote la memoria del celular
    return VisibilityDetector(
      key: Key(widget.videoUrl),
      onVisibilityChanged: (info) {
        if (!mounted) return;

        if (info.visibleFraction > 0.5) {
          // Si el video entra a la pantalla, lo construimos y le damos play
          if (!_isInitialized && !_hasError) {
            _initController();
          } else if (_isInitialized && _controller != null && !_controller!.value.isPlaying) {
            _controller!.play();
          }
        } else if (info.visibleFraction == 0.0) {
          // 🔥 SI EL VIDEO SALE DE LA PANTALLA, LO DESTRUIMOS PARA SALVAR LA MEMORIA (Evita el Crash)
          if (_isInitialized) {
            _disposeController();
            setState(() {});
          }
        } else {
          // Si está a medias, lo pausamos
          if (_isInitialized && _controller != null && _controller!.value.isPlaying) {
            _controller!.pause();
          }
        }
      },
      child: GestureDetector(
        onTap: () {
          // 🎬 AL TOCAR: Abrimos la nueva pantalla como YouTube
          if (_isInitialized && _controller != null) {
            _controller!.pause();
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenVideoPlayer(
                videoUrl: widget.videoUrl,
                title: widget.title,
              ),
            ),
          ).then((_) {
            // Al regresar, si sigue en pantalla, reanudamos la vista previa
            if (mounted && _isInitialized && _controller != null) {
              _controller!.play();
            }
          });
        },
        child: Container(
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_isInitialized && _controller != null)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: VideoPlayer(_controller!),
                )
              else if (_hasError)
                const AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Icon(Icons.error_outline, color: Colors.white24, size: 48),
                )
              else
                const AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Center(child: CircularProgressIndicator(color: AppTheme.orange)),
                ),

              // Icono que le indica al usuario que puede tocar para expandir
              if (_isInitialized)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.open_in_new, color: Colors.white, size: 18),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================
// 2. LA NUEVA PANTALLA COMPLETA (Al darle Tap)
// =======================================================
class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;

  const FullScreenVideoPlayer({super.key, required this.videoUrl, required this.title});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _fullController;
  bool _isInitialized = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    String finalUrl = widget.videoUrl;
    String currentBaseUrl = dotenv.env['API_URL'] ?? '';

    if (currentBaseUrl.isNotEmpty && finalUrl.contains('/uploads/')) {
      String serverHost = currentBaseUrl.replaceAll('/api', ''); 
      String fileName = finalUrl.split('/uploads/').last;
      finalUrl = '$serverHost/uploads/$fileName';
    }

    _fullController = VideoPlayerController.networkUrl(
      Uri.parse(finalUrl),
      httpHeaders: {'ngrok-skip-browser-warning': 'true'},
    );
    _fullController.initialize().then((_) {
      if (mounted) {
        _fullController.play(); // Aquí sí arranca con sonido
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _fullController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: _isInitialized
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _showControls = !_showControls;
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _fullController.value.aspectRatio,
                      child: VideoPlayer(_fullController),
                    ),
                    
                    if (_showControls)
                      Container(color: Colors.black.withOpacity(0.4)),
                    
                    if (_showControls)
                      IconButton(
                        icon: Icon(
                          _fullController.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          color: Colors.white,
                          size: 80,
                        ),
                        onPressed: () {
                          setState(() {
                            _fullController.value.isPlaying ? _fullController.pause() : _fullController.play();
                          });
                        },
                      ),
                    
                    if (_showControls)
                      Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: VideoProgressIndicator(
                          _fullController,
                          allowScrubbing: true,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          colors: const VideoProgressColors(
                            playedColor: AppTheme.orange,
                            bufferedColor: Colors.white54,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                      ),
                  ],
                ),
              )
            : const CircularProgressIndicator(color: AppTheme.orange),
      ),
    );
  }
}