import 'package:flutter/material.dart';

import '../models/book.dart';
import '../utils/format.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.onOpen,
    required this.onFavourite,
  });

  final Book book;
  final VoidCallback onOpen;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: book.genre.color(scheme),
                    child: Icon(book.genre.icon, color: scheme.onSurface),
                  ),
                  if (book.isFull || book.free <= 5)
                    Positioned(
                      bottom: -8,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.inverseSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          book.isFull ? 'FULL' : '${book.free} left',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: scheme.onInverseSurface),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatMeeting(book.meetingDate),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      book.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (book.isPast)
                      Text(
                        'Past meeting',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onFavourite,
                tooltip: book.favourite ? 'Remove favourite' : 'Add favourite',
                icon: Icon(
                  book.favourite ? Icons.favorite : Icons.favorite_border,
                ),
                color: scheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
