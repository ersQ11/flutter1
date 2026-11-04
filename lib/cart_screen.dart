import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _totalExpanded = true;

  Future<void> _clearCart(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('Remove all books from the cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (confirmed == true) context.read<Cart>().clear();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Cart'),
      actions: [
        IconButton(
          tooltip: 'Clear cart',
          onPressed: () => _clearCart(context),
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    ),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Consumer<Cart>(
              builder: (context, cart, _) => cart.count == 0
                  ? const Center(child: Text('Your cart is empty'))
                  : ListView(
                      children: [
                        for (final b in cart.items)
                          ListTile(
                            title: Text(b.title),
                            subtitle: Text('${b.author}\n${b.price} ₸ each'),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Decrease quantity of ${b.title}',
                                  icon: const Icon(Icons.remove),
                                  onPressed: cart.qtyOf(b) > 1
                                      ? () => cart.decrement(b)
                                      : null,
                                ),
                                Text('×${cart.qtyOf(b)}'),
                                IconButton(
                                  tooltip: 'Increase ${b.title}',
                                  icon: const Icon(Icons.add),
                                  onPressed: () => cart.increment(b),
                                ),
                                IconButton(
                                  tooltip: 'Remove ${b.title}',
                                  icon: const Icon(Icons.close),
                                  onPressed: () => cart.remove(b),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('Order summary')),
                    IconButton(
                      tooltip: _totalExpanded ? 'Hide total' : 'Show total',
                      onPressed: () =>
                          setState(() => _totalExpanded = !_totalExpanded),
                      icon: Icon(
                        _totalExpanded ? Icons.expand_less : Icons.expand_more,
                      ),
                    ),
                  ],
                ),
                if (_totalExpanded)
                  Consumer<Cart>(
                    child: const _TotalLabel(),
                    builder: (context, cart, child) => Row(
                      children: [
                        child!,
                        const Spacer(),
                        Text(
                          '${cart.total} ₸',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _TotalLabel extends StatelessWidget {
  const _TotalLabel();

  @override
  Widget build(BuildContext context) => const Row(
    mainAxisSize: MainAxisSize.min,
    children: [Icon(Icons.receipt_long), SizedBox(width: 8), Text('Total')],
  );
}
