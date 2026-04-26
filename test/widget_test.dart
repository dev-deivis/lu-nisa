import 'package:flutter_test/flutter_test.dart';
import 'package:lunisa/main.dart';
import 'package:provider/provider.dart';
import 'package:lunisa/core/providers/app_provider.dart';

void main() {
  testWidgets('LunisaApp arranca sin errores', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const LunisaApp(),
      ),
    );
    expect(find.text('Lu-nisa'), findsOneWidget);
  });
}
