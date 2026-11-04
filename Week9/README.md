# Practice 09 Put It High Subscribe Low

Магазин книг по материалам лекций Flutter I. Два экрана — Books и Cart,
одна корзина в ChangeNotifier, маршруты через Navigator.pushNamed.
Интерфейс использует обычные AppBar, ListTile, OutlinedButton, Badge,
SnackBar и AlertDialog, как в примерах лекций.

## Запуск

Распакуйте архив вместе со скрытой папкой `.git` и откройте папку shop.
Установите Flutter, затем выполните:

```shell
flutter pub get
flutter run -d chrome
```

Для телефона или Android-эмулятора выберите его из `flutter devices`
и используйте `flutter run -d <device-id>`.

## Что реализовано

- Шесть книг из задания и поиск по названию или автору.
- Add и Added, SnackBar только после успешного добавления.
- Badge с количеством разных книг и отдельная живая сумма.
- Cart с количеством, увеличением, удалением и итогом.
- Сворачивание итога как локальное состояние экрана.
- Очистка только после подтверждения диалога.
- Provider над MaterialApp, select по count, Consumer с const child.
- Приватная карта количеств и неизменяемый список items.

## Файлы

```text
lib/
  main.dart
  books_screen.dart
  cart_badge.dart
  cart_screen.dart
  models/
    book.dart
    cart.dart
test/
  cart_test.dart
  shop_test.dart
  scope_test.dart
tool/
  screenshots_test.dart
NOTES.md
screenshot_books.png
screenshot_cart.png
```

NOTES.md содержит результаты измерений, ошибки watch/read и объяснение,
где хранится каждое состояние. Измерения получены выполнением тестов.

## Проверка

```shell
dart format .
flutter analyze
flutter test
```

Повторное получение PNG на Windows, где Flutter установлен в C:\dev\flutter:

```powershell
$env:FLUTTER_ROOT = 'C:\dev\flutter'
flutter test tool/screenshots_test.dart
```

Если SDK расположен иначе, укажите его путь. Тест делает реальные снимки
виджетов Flutter и сохраняет их в корне проекта.
