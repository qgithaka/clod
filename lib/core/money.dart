import 'package:intl/intl.dart';

class Money {
  final int cents;

  const Money(this.cents);

  factory Money.fromDouble(double amount) {
    return Money((amount * 100).round());
  }

  factory Money.parse(String formatted) {
    final clean = formatted.replaceAll(RegExp(r'[^0-9.-]'), '');
    if (clean.isEmpty) return const Money(0);
    final val = double.tryParse(clean) ?? 0.0;
    return Money.fromDouble(val);
  }

  double get asDouble => cents / 100.0;

  String format({String currencyCode = 'USD', bool symbol = true}) {
    final format = NumberFormat.currency(
      name: currencyCode,
      symbol: symbol ? null : '',
    );
    return format.format(asDouble);
  }

  Money operator +(Money other) => Money(cents + other.cents);
  Money operator -(Money other) => Money(cents - other.cents);
  Money operator *(num multiplier) => Money((cents * multiplier).round());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          runtimeType == other.runtimeType &&
          cents == other.cents;

  @override
  int get hashCode => cents.hashCode;

  @override
  String toString() => format();
}
