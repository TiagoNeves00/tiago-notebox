import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double progress = 0;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    // o nativo pode sair agora
    FlutterNativeSplash.remove();

    // define aqui as tuas tarefas reais de arranque
    final steps = <Future<void> Function()>[
      // ignore: inference_failure_on_instance_creation
      () async { /* open DB */ await Future.delayed(const Duration(milliseconds: 300)); },
      // ignore: inference_failure_on_instance_creation
      () async { /* load settings */ await Future.delayed(const Duration(milliseconds: 300)); },
      // ignore: inference_failure_on_instance_creation
      () async { /* warm caches */ await Future.delayed(const Duration(milliseconds: 400)); },
    ];

    for (var i = 0; i < steps.length; i++) {
      await steps[i]();
      if (!mounted) return;
      setState(() => progress = (i + 1) / steps.length);
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      // ignore: inference_failure_on_instance_creation
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA9C6E6), // igual ao splash nativo
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // usa o mesmo foreground do ícone
              Image.asset(
                'assets/icon/ic_foreground.png',
                width: 160,
                height: 160,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 220,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,                  // 0..1
                    minHeight: 8,
                    color: const Color(0xFFE6ABA9),  // barra
                    backgroundColor: Colors.white24, // trilho
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// placeholder
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Home')));
}
