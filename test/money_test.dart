import 'package:flutter_test/flutter_test.dart';
import 'package:clod/core/money.dart';

void main() {
  group('Money', () {
    test('creates from double correctly', () {
      expect(Money.fromDouble(10.50).cents, 1050);
      expect(Money.fromDouble(0.99).cents, 99);
      expect(Money.fromDouble(1234.56).cents, 123456);
    });

    test('parses formatted string correctly', () {
      expect(Money.parse('\$10.50').cents, 1050);
      expect(Money.parse('€ 0.99').cents, 99);
      expect(Money.parse('1,234.56').cents, 123456);
    });

    test('formats to string correctly', () {
      expect(const Money(1050).format(currencyCode: 'USD'), 'USD10.50');
      expect(
        const Money(123456).format(currencyCode: 'USD', symbol: false),
        '1,234.56',
      );
    });

    test('supports arithmetic operations', () {
      final a = const Money(100);
      final b = const Money(50);

      expect((a + b).cents, 150);
      expect((a - b).cents, 50);
      expect((a * 3).cents, 300);
      expect((a * 1.5).cents, 150);
    });

    test('equality checks work', () {
      expect(const Money(100) == const Money(100), isTrue);
      expect(const Money(100) == const Money(200), isFalse);
    });
  });
}
