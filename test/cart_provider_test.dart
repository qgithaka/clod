import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clod/core/providers/cart_provider.dart';
import 'package:clod/core/money.dart';
import 'package:clod/domain/entities/item_entity.dart';
import 'package:clod/domain/entities/customer_entity.dart';

void main() {
  test('CartNotifier adds items, calculates subtotal, updates quantities', () {
    final container = ProviderContainer();
    final notifier = container.read(cartProvider.notifier);

    final item1 = ItemEntity(
      id: 1, name: 'Apple', type: ItemType.product, sellingPrice: const Money(150), isActive: true, createdAt: DateTime.now(),
    );
    final item2 = ItemEntity(
      id: 2, name: 'Banana', type: ItemType.product, sellingPrice: const Money(200), isActive: true, createdAt: DateTime.now(),
    );

    notifier.addItem(item1);
    expect(container.read(cartProvider).items.length, 1);
    expect(container.read(cartProvider).total.cents, 150);

    notifier.addItem(item1); // quantity should become 2
    expect(container.read(cartProvider).items.length, 1);
    expect(container.read(cartProvider).items[0].quantity, 2);
    expect(container.read(cartProvider).total.cents, 300);

    notifier.addItem(item2);
    expect(container.read(cartProvider).items.length, 2);
    expect(container.read(cartProvider).total.cents, 500);

    // update quantity
    notifier.updateQuantity(2, 3);
    expect(container.read(cartProvider).total.cents, 300 + (3 * 200));

    // override price
    notifier.updateOverridePrice(1, const Money(100));
    expect(container.read(cartProvider).total.cents, (2 * 100) + (3 * 200));

    // remove item
    notifier.removeItem(2);
    expect(container.read(cartProvider).items.length, 1);
    expect(container.read(cartProvider).total.cents, 200);
    
    // update quantity to 0 removes it
    notifier.updateQuantity(1, 0);
    expect(container.read(cartProvider).items.isEmpty, true);
  });

  test('CartNotifier attach and detach customer', () {
    final container = ProviderContainer();
    final notifier = container.read(cartProvider.notifier);
    
    final cust = CustomerEntity(
      id: 1, name: 'John', currentBalance: const Money(0), creditLimit: const Money(1000), isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now(),
    );
    
    expect(container.read(cartProvider).customer, isNull);
    
    notifier.attachCustomer(cust);
    expect(container.read(cartProvider).customer?.name, 'John');
    
    notifier.detachCustomer();
    expect(container.read(cartProvider).customer, isNull);
  });
}
