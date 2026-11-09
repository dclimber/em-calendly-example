import 'package:em_calendly_example/platform/view_store/view_state_store.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

/// The behavior that every [ViewStateStore] adapter shares.
void viewStateStoreContract(ViewStateStore Function() store) {
  late String view;
  setUp(() => view = 'test-${const Uuid().v4()}');

  // @ensures get(put(k, d)) == d, and a second put replaces the document
  test('puts, replaces, and gets a document', () async {
    final s = store();
    await s.put(view, 'a', {'n': 1});
    await s.put(view, 'a', {
      'n': 2,
      'list': ['x'],
    });
    expect(await s.get(view, 'a'), {
      'n': 2,
      'list': ['x'],
    });
    expect(await s.get(view, 'missing'), isNull);
  });

  // @ensures delete removes only the document of its key
  test('deletes a document', () async {
    final s = store();
    await s.put(view, 'a', {'n': 1});
    await s.put(view, 'b', {'n': 2});
    await s.delete(view, 'a');
    expect(await s.get(view, 'a'), isNull);
    expect(await s.get(view, 'b'), {'n': 2});
  });

  // @ensures find returns the documents that contain the pattern, ordered by key
  test('finds documents by JSON containment', () async {
    final s = store();
    await s.put(view, 'b', {
      'hostId': 'alice',
      'tags': ['x', 'y'],
    });
    await s.put(view, 'a', {
      'hostId': 'alice',
      'tags': ['y'],
    });
    await s.put(view, 'c', {
      'hostId': 'bob',
      'tags': ['x'],
    });
    expect((await s.find(view, where: {'hostId': 'alice'})).map((d) => d['tags']), [
      ['y'],
      ['x', 'y'],
    ]);
    expect(
      (await s.find(
        view,
        where: {
          'tags': ['x'],
        },
      )).map((d) => d['hostId']),
      ['alice', 'bob'],
    );
    expect(await s.find(view), hasLength(3));
  });
}
