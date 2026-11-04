import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('badge build');
    final n = context.select<Cart, int>((c) => c.count);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _BadgeTotal(),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Badge(
            label: Text('$n'),
            child: IconButton(
              tooltip: 'Open cart',
              icon: const Icon(Icons.shopping_cart),
              onPressed: () => Navigator.of(context).pushNamed('/cart'),
            ),
          ),
        ),
      ],
    );
  }
}

// The total changes with quantities; its subscription stays below the badge.
class _BadgeTotal extends StatelessWidget {
  const _BadgeTotal();

  @override
  Widget build(BuildContext context) =>
      Consumer<Cart>(builder: (context, cart, _) => Text('${cart.total} ₸'));
}
