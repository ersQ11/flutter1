# Practice 09

## Level 1 Lift it up

The cart belongs to Shell above MaterialApp. BooksScreen and CartScreen
receive the same list and call callbacks; neither screen owns it.

Adding the total to the badge changed **2 constructors**:

- `lib/books_screen.dart`: added `total` and forwarded it to the badge.
- `lib/cart_badge.dart`: added `total` and displayed it.

`lib/main.dart` also changed: Shell computes and passes total at the
BooksScreen call site. Shell's constructor did not change. CartScreen
already computes its total from items, so its constructor did not change.

Measured by `flutter test test/lifted_test.dart`: one Add produces
**1 BooksScreen build + 6 row lines = 7 diagnostic lines**.
Initial builds and Navigator animation frames are excluded.
The test also adds two books, removes one on the other route and returns.
