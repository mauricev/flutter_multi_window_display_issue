import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:macos_dialog_first_frame_repro/main.dart';

void main() {
  testWidgets('renders the multiview repro surface', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ReproWindowSurface());

    expect(find.text('macOS multiview repro'), findsOneWidget);
    expect(
      find.text(
        'This app should open two identical Flutter-backed macOS windows.',
      ),
      findsOneWidget,
    );
  });
}
