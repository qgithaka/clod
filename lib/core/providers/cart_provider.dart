import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/money.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/entities/customer_entity.dart';

class CartLineItem {
  final ItemEntity item;
  final int quantity;
  final Money overridePrice;

  CartLineItem({
    required this.item,
    required this.quantity,
    Money? price,
  }) : overridePrice = price ?? item.sellingPrice;

  Money get lineTotal => Money(overridePrice.cents * quantity);

  CartLineItem copyWith({int? quantity, Money? overridePrice}) {
    return CartLineItem(
      item: item,
      quantity: quantity ?? this.quantity,
      price: overridePrice ?? this.overridePrice,
    );
  }
}

class CartState {
  final List<CartLineItem> items;
  final CustomerEntity? customer;

  CartState({this.items = const [], this.customer});

  Money get subtotal {
    int totalCents = 0;
    for (var item in items) {
      totalCents += item.lineTotal.cents;
    }
    return Money(totalCents);
  }

  Money get total => subtotal; // Can add global discounts later if needed

  CartState copyWith({List<CartLineItem>? items, CustomerEntity? customer, bool clearCustomer = false}) {
    return CartState(
      items: items ?? this.items,
      customer: clearCustomer ? null : (customer ?? this.customer),
    );
  }
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    return CartState();
  }

  void addItem(ItemEntity item) {
    final existingIndex = state.items.indexWhere((i) => i.item.id == item.id);
    if (existingIndex >= 0) {
      final existing = state.items[existingIndex];
      final updated = List<CartLineItem>.from(state.items);
      updated[existingIndex] = existing.copyWith(quantity: existing.quantity + 1);
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(items: [...state.items, CartLineItem(item: item, quantity: 1)]);
    }
  }

  void updateQuantity(int itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(itemId);
      return;
    }
    final existingIndex = state.items.indexWhere((i) => i.item.id == itemId);
    if (existingIndex >= 0) {
      final existing = state.items[existingIndex];
      final updated = List<CartLineItem>.from(state.items);
      updated[existingIndex] = existing.copyWith(quantity: newQuantity);
      state = state.copyWith(items: updated);
    }
  }
  
  void updateOverridePrice(int itemId, Money newPrice) {
    final existingIndex = state.items.indexWhere((i) => i.item.id == itemId);
    if (existingIndex >= 0) {
      final existing = state.items[existingIndex];
      final updated = List<CartLineItem>.from(state.items);
      updated[existingIndex] = existing.copyWith(overridePrice: newPrice);
      state = state.copyWith(items: updated);
    }
  }

  void removeItem(int itemId) {
    final updated = state.items.where((i) => i.item.id != itemId).toList();
    state = state.copyWith(items: updated);
  }

  void attachCustomer(CustomerEntity customer) {
    state = state.copyWith(customer: customer);
  }

  void detachCustomer() {
    state = state.copyWith(clearCustomer: true);
  }

  void clearCart() {
    state = CartState();
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(() {
  return CartNotifier();
});
