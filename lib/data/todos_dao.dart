import 'package:moor/moor.dart';
import 'database.dart';

part 'todos_dao.g.dart';

// the _TodosDaoMixin will be created by moor. It contains all the necessary
// fields for the tables. The <MyDatabase> type annotation is the database class
// that should use this dao.
@UseDao(tables: [Todos])
class TodosDao extends DatabaseAccessor<MyDatabase> with _$TodosDaoMixin {
  static TodosDao? _instance;

  static TodosDao get instance =>
      _instance ??= new TodosDao(MyDatabase.instance);

  // this constructor is required so that the main database can create an instance
  // of this object.
  TodosDao(MyDatabase db) : super(db);

  Stream<List<Todo>> todosInCategory(Category category) {
    if (category == null) {
      return (select(todos)..where((t) => isNull(t.category))).watch();
    } else {
      return (select(todos)..where((t) => t.category.equals(category.id)))
          .watch();
    }
  }

  Stream<List<Todo>> selectAllStream() {
    return (select(todos)).watch();
  }

  Future<List<Todo>> selectAll() => select(todos).get();

  // returns the generated id
  Future<int> addTodo(TodosCompanion entry) {
    return into(todos).insert(entry);
  }

  Future<int> insert(String title, String content) {
    return addTodo(
      TodosCompanion(
        title: Value(title),
        content: Value(content),
      ),
    );
  }

  Future deleteItem(Todo todo) {
    // delete the oldest nine tasks
    return (delete(todos)..where((t) => t.id.equals(todo.id))).go();
  }
}
