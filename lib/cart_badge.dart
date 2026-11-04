import 'package:flutter/material.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key, required this.count, required this.total});

  final int count;
  final int total;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('$total ₸'),
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Badge(
          label: Text('$count'),
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
