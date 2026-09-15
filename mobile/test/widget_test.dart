import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('Blog App berhasil dijalankan', (WidgetTester tester) async {
    await tester.pumpWidget(const BlogApp());

    expect(find.text('BLOG APP'), findsOneWidget);
    expect(find.text('Artikel Terbaru'), findsOneWidget);
  });
}