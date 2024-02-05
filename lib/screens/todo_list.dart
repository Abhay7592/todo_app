import 'package:flutter/material.dart';
import 'package:todo_app/screens/add_page.dart';
import 'package:todo_app/services/todo_services.dart';
import '../utils/snackbar_helper.dart';
import '../widget/todo_card.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List items = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo List"),
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(
          child: CircularProgressIndicator(),
        ),
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(
              child: Text(
                "No Todo Item",
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            child: ListView.builder(
              itemCount: items.length,
              padding: EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                // final id = item['_id'] as String;
                return TodoCard(
                  index: index,
                  deleteById: deleteById,
                  item: item,
                  navigateEdit: navigateToEditPage,
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          navigateToAddPage();
        },
        label: Text('Add Todo'),
      ),
    );
  }

  Future<void> deleteById(String id) async {
    //delete the item

    final isSuccess = await TodoService.deleteById(id);
    if (isSuccess) {
      //remove item from the list
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      //show error
      showErrorMessage(context, message: "Unable to delete");
    }
    //remove the item from the current list
  }

  Future<void> fetchTodo() async {
    final response = await TodoService.fetchTodos();

    if (response != null) {
      // Assuming you have a state variable to store the fetched data
      setState(() {
        // Update your state variable with the fetched data
        items = response;
      });
    } else {
      showErrorMessage(context, message: "Something went Wrong");
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }
}
