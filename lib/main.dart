// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/_window.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runWidget(const MultiWindowReproApp());
}

class _QuitOnCloseDelegate with RegularWindowControllerDelegate {
  @override
  void onWindowDestroyed() {
    exit(0);
  }
}

class MultiWindowReproApp extends StatefulWidget {
  const MultiWindowReproApp({super.key});

  @override
  State<MultiWindowReproApp> createState() => _MultiWindowReproAppState();
}

class _MultiWindowReproAppState extends State<MultiWindowReproApp> {
  static const MethodChannel _windowChannel = MethodChannel('repro/window');

  late final List<RegularWindowController> _controllers =
      List<RegularWindowController>.generate(2, (_) {
        final RegularWindowController controller = RegularWindowController(
          preferredSize: const Size(650, 470),
          title: 'Native macOS Host Window (Repro)',
          delegate: _QuitOnCloseDelegate(),
        );
        controller.setMinimized(true);
        return controller;
      });

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _arrangeReproWindows();
      for (final RegularWindowController controller in _controllers) {
        controller.setMinimized(false);
        controller.activate();
      }
    });
  }

  Future<void> _arrangeReproWindows() async {
    try {
      await _windowChannel.invokeMethod<void>('arrangeReproWindows');
    } on MissingPluginException {
      // Widget tests run without native window wiring.
    }
  }

  @override
  void dispose() {
    for (final RegularWindowController controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewCollection(
      views: _controllers
          .map(
            (RegularWindowController controller) => RegularWindow(
              controller: controller,
              child: const ReproWindowSurface(),
            ),
          )
          .toList(),
    );
  }
}

class ReproWindowSurface extends StatelessWidget {
  const ReproWindowSurface({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF245C4C)),
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    blurRadius: 28,
                    offset: Offset(0, 18),
                    color: Color(0x22000000),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'macOS multiview repro',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'This app should open two identical Flutter-backed macOS windows.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Each window title should say "Native macOS Host Window (Repro)".',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'What to look for: when the windows appear, does either one briefly show only the orange host background before this white Flutter panel appears?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD7E0DC)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Expected result',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Both windows should show the same white Flutter panel over the orange host background.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'If either window briefly shows only the orange host background first, that is the behavior we are trying to catch.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
