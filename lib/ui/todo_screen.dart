import 'package:flutter/material.dart';
import 'package:todo/model/todo_item.dart';
import 'package:todo/util/database_client.dart';
import 'package:snack/snack.dart';
import 'package:todo/util/date_formatter.dart';

class todoScreen extends StatefulWidget {
  @override
  _todoScreenState createState() => _todoScreenState();
}

class _todoScreenState extends State<todoScreen> {
  final _textEditingController = new TextEditingController();
  var db = new DatabaseHelper();
  final List<todoItem> _itemsList = [];
  @override
  void initState() {
    super.initState();
    _readToDoList();
  }

  void _handleSubmitted(String text) async {
    _textEditingController.clear();
    todoItem item = new todoItem(text, dateFormatted());
    int savedItemId = await db.saveItem(item);
    todoItem addedItem = await db.getItem(savedItemId);
    setState(() {
      _itemsList.insert(0, addedItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
                padding: EdgeInsets.all(7),
                reverse: false,
                itemCount: _itemsList.length,
                itemBuilder: (_, int index) {
                  return Card(
                    color: Colors.white10,
                    child: ListTile(
                      title: _itemsList[index],
                      onLongPress: () => _updateToDo(_itemsList[index], index),
                      trailing: new Listener(
                        key: Key(_itemsList[index].itemName),
                        child: Icon(
                          Icons.remove_circle,
                          color: Colors.redAccent,
                        ),
                        onPointerDown: (pointerEvent) {
                          _showDeleteDialog(_itemsList[index].id, index);
                        },
                      ),
                    ),
                    elevation: 2,
                  );
                }),
          ),
          Divider(
            height: 1.0,
          ),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
          tooltip: 'Add Item',
          backgroundColor: Colors.redAccent,
          child: new ListTile(
            title: Icon(Icons.add),
          ),
          onPressed: _showFormDialog),
    );
  }

  void _showFormDialog() {
    var alert = new AlertDialog(
      title: Text("Add new TO-DO"),
      content: Row(
        children: [
          Expanded(
              child: TextField(
            controller: _textEditingController,
            autofocus: true,
            decoration: InputDecoration(
                labelText: "Item",
                hintText: "eg. buy cookies",
                icon: Icon(Icons.note_add_outlined)),
          )),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              String text = _textEditingController.text;
              if (!text.isEmpty) {
                _handleSubmitted(text);
                _textEditingController.clear();
              } else {
                SnackBar(
                  content: Text(
                    "Can't Add Empty Field!!",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  backgroundColor: Colors.lightBlueAccent,
                ).show(context);
              }
              Navigator.pop(context);
            },
            child: Text("Save")),
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text("Cancel")),
      ],
      elevation: 8.0,
      backgroundColor: Colors.yellow.shade500,
    );
    showDialog(
      context: context,
      builder: (_) {
        return alert;
      },
      barrierDismissible: true,
    );
  }

  _readToDoList() async {
    List items = await db.getItems();
    items.forEach((element) {
      setState(() {
        _itemsList.add(todoItem.map(element));
      });
    });
  }

  void _deleteToDo(int id, int index) async {
    await db.deleteItem(id);
    setState(() {
      _itemsList.removeAt(index);
    });
  }

  void _showDeleteDialog(int id, int index) {
    var alert = new AlertDialog(
      content: Row(
        children: [
          Expanded(child: Text("Are You Sure You want to Delete?")),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              _deleteToDo(id, index);
              Navigator.pop(context);
            },
            child: Text("YES")),
        TextButton(onPressed: () => Navigator.pop(context), child: Text("NO")),
      ],
    );
    showDialog(
      context: context,
      builder: (_) {
        return alert;
      },
      barrierDismissible: true,
    );
  }

  void _updateToDo(todoItem item, int index) {
    int id = _itemsList[index].id;
    _textEditingController.text = _itemsList[index].itemName;
    var alert = new AlertDialog(
      title: Text("Update TO-DO"),
      content: Row(
        children: [
          Expanded(
              child: TextField(
            controller: _textEditingController,
            autofocus: true,
            decoration: InputDecoration(
                //prefix: Text(_itemsList[index].itemName),
                labelText: "Item",
                hintText: "eg. buy cookies",
                icon: Icon(Icons.update)),
          )),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () async {
              String text = _textEditingController.text;
              if (!text.isEmpty) {
                todoItem newItemUpdated = todoItem.fromMap({
                  "itemName": _textEditingController.text,
                  "dateCreated": dateFormatted(),
                  "id": item.id
                });
                _handleSubmittedUpdate(index, item);
                await db.updateItem(newItemUpdated);
                setState(() {
                  _readToDoList();
                });
              } else {
                SnackBar(
                  content: Text(
                    "Can't Add Empty Field!!",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  backgroundColor: Colors.lightBlueAccent,
                ).show(context);
              }
              _textEditingController.clear();
              Navigator.pop(context);
            },
            child: Text("Update")),
        TextButton(
            onPressed: () {
              _textEditingController.clear();
              Navigator.pop(context);
            },
            child: Text("Cancel")),
      ],
      elevation: 8.0,
      backgroundColor: Colors.greenAccent,
    );
    showDialog(
      context: context,
      builder: (_) {
        return alert;
      },
      barrierDismissible: true,
      // barrierColor: Colors.grey.shade900,
    );
  }

  void _handleSubmittedUpdate(int index, todoItem item) {
    setState(() {
      _itemsList.removeWhere((element) {
        _itemsList[index].id == item.id;
      });
    });
  }
}
