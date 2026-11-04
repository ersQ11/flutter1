# Practice 09 Put It High Subscribe Low

## Level 1 Lift it up

Корзина принадлежит Shell над MaterialApp. Два экрана получают одну
коллекцию через параметры и меняют её через callbacks.

Для суммы в badge изменены **2 конструктора**:

- `lib/books_screen.dart`: добавлен `total`, передаваемый дальше в CartBadge.
- `lib/cart_badge.dart`: добавлен `total`, который отображается рядом с иконкой.

В `lib/main.dart` также изменён вызов BooksScreen: владелец вычисляет сумму
и передаёт её вниз. Конструктор Shell не изменён. CartScreen уже получает
items и вычисляет свою сумму, поэтому его конструктор не менялся.

Первая версия сохранена в коммите **lifted**. Её можно посмотреть командой
`git show HEAD~1:lib/main.dart`. Чтобы запустить отдельно и не менять
финальную версию: `git worktree add ../shop_lifted HEAD~1`.

Измерение из `test/lifted_test.dart` в первом коммите, после начальной
отрисовки, одно нажатие Add:

```text
LIFTED MEASUREMENT: screen=1 rows=6 total=7
```

Это **7 диагностических строк**: один BooksScreen и все шесть строк книг.
Тест также проверил две добавленные книги, удаление на другом маршруте
и возврат с обновлённой корзиной. Начальные построения не учитывались.

## Level 2 A model with no widgets

Book и список книг перенесены в `lib/models/book.dart`.
Cart в `lib/models/cart.dart` содержит приватную Map<Book, int>.
Внешний код получает List.unmodifiable, а не доступ к приватной карте.

`add` возвращает false для повторной книги, не меняет количество и не
вызывает notifyListeners. Количество увеличивается только через increment.
count считает разные книги, total учитывает цену и количество. remove
удаляет всю позицию. increment отсутствующей книги ничего не делает.

Проверка модели без экрана в `test/cart_test.dart`:
добавить первые две книги, повторно добавить первую, удалить первую.

```text
1 items, 3100 ₸
```

Попытка изменить cart.items снаружи даёт UnsupportedError. Проверены
и add, и clear на возвращаемом списке. Модели не используют BuildContext,
Navigator или SnackBar. Единственный импорт Flutter в cart.dart —
foundation.dart; второй импорт — собственный book.dart.

ChangeNotifier относится к Flutter foundation: «без экрана» означает
без runApp и pumpWidget, а не полную независимость от Flutter SDK.

## Level 3 The same app with provider

ChangeNotifierProvider(create: ...) создан один раз над Shell и MaterialApp.
Shell — StatelessWidget. Параметры корзины и callbacks из конструкторов
экранов удалены. В production-коде нет передачи `cart:` через дерево.

- Строка книги: watch внутри build для Added, read в onPressed для add.
- Список корзины: Consumer<Cart>; в builder уже доступен cart.
- Badge: в финальной версии select по count.
- Модель возвращает bool, а виджет решает, показывать ли SnackBar Added.

Оба намеренно неверных варианта проверены в `test/scope_test.dart`.
В финальном lib/ они не используются.

**watch в onPressed — громкая ошибка.** Получен AssertionError:

```text
Tried to listen to a value exposed with provider, from outside of the widget tree.
```

Установленный provider 6.1.5+1 предлагает исправление
`Provider.of<Cart>(context, listen: false)`. В приложении используется
равнозначный `context.read<Cart>()` в callback.

**read в build — тихая ошибка.** Текста исключения нет. Тест изменил
модель с count 0 на 1, но надпись осталась `read count: 0`.
В лекции приведена также формулировка возможной отладочной диагностики
для read в build; в установленной версии такого assertion не возникло.
Наблюдаемый результат — отсутствие подписки и устаревшее значение.

## Level 4 Scope

Измерение `test/scope_test.dart`: один Cart, одна добавленная книга,
три вызова increment с отдельным pump после каждого. Счётчик watch
и настоящий CartBadge с select присутствуют одновременно. Первые
построения исключены, считаются только перестроения после изменений.

```text
SCOPE MEASUREMENT: watch=3 select=0
```

При remove настоящий CartBadge перестроился **1 раз**.
count при трёх increment оставался равен 1, а total менялся.
Это автоматическое измерение вызовов build в widget-тесте;
интерактивный счётчик DevTools отдельно не запускался.

Для ручного повторения: flutter run, включить Track widget builds
в DevTools, добавить книгу, открыть Cart, нажать + три раза. Затем
в CartBadge заменить select на watch, перезапустить и повторить.

Сумма рядом с badge находится в отдельном _BadgeTotal с Consumer.
Поэтому при изменении количества сумма обновляется, но CartBadge.build
не вызывается. В CartScreen Consumer для итога получает const _TotalLabel
через child и вставляет child! в builder. Этот статический дочерний
виджет не перестраивается при уведомлениях корзины.

BooksScreen не подписан на Cart. Подписки watch находятся в маленьких
_BookRow. Эти строки пока перестраиваются на уведомлениях; сам экран
и поле поиска не перестраиваются от изменения корзины.
Если перенести watch в BooksScreen.build, на каждое уведомление
перестроятся весь экран и созданные им строки, включая скрытый маршрут.

## Level 5 Logic on the right side

SnackBar создаётся в onPressed только после успешного add.
Проверка дубликатов находится в модели. После обновления строки кнопка
Add заменяется на Added; повторный add программно возвращает false.

Clear cart открывает showDialog<bool>. Cancel возвращает false,
Clear возвращает true. После await проверяется context.mounted,
и только подтверждение вызывает clear через read. Ни вопрос,
ни навигация диалога не входят в модель.

## Where does it live?

- **Cart — provided:** его используют два маршрута и badge; владелец ChangeNotifierProvider находится над MaterialApp.
- **Search text — lifted:** BooksScreen хранит TextEditingController и объединяет поле поиска со списком, который оно фильтрует; onChanged вызывает локальный setState, controller освобождается в dispose.
- **Total expanded or collapsed — ephemeral:** _totalExpanded принадлежит State<CartScreen>, потому что влияет только на представление одного экрана.
- **Theme mode — provided:** при появлении общего переключателя режим жил бы в модели настроек над MaterialApp, чтобы оба маршрута использовали одну тему; сейчас переключатель не реализован и не требуется.

## Validation

Проверено с Flutter 3.47.6, Dart 3.13.5 и provider 6.1.5+1:

- `dart format .` выполнен.
- `flutter analyze`: No issues found!
- `flutter test test tool/screenshots_test.dart`: 6 тестов, все успешны.
- `flutter build web`: сборка завершена успешно.
- Первая lifted-версия отдельно прошла свой widget-тест до первого коммита.
- screenshot_books.png: две разные книги, badge 2, сумма 7300 ₸.
- screenshot_cart.png: первая книга ×2, вторая ×1, сумма 11500 ₸.

PNG получены из настоящей отрисовки Flutter в widget-тесте, а не
сфотографированы с эмулятора. Размер тестового окна 480×1000,
pixelRatio снимка 2. Для снимков на Windows загружены системный
текстовый шрифт и MaterialIcons, чтобы не использовать тестовый Ahem.
