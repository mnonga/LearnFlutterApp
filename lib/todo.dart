import 'package:bible/data/database.dart';
import 'package:flutter/material.dart';

import 'models.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:cached_network_image/cached_network_image.dart';

import 'profile.dart';

import 'package:bible/data/todos_dao.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  static const routeName = '/todo';

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  late Future<List<Todo>> futureTodos;
  late Stream<List<Todo>> streamTodos;
  int page = 1;

  void handleClick(String? value) {
    switch (value) {
      case 'Logout':
        break;
      case 'Settings':
        break;
    }
  }

  Future<String?> _showMyDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) => AlertDialog(
        title: const Text('AlertDialog Title'),
        content: const Text('Voulez-vous supprimer cet utilisateur ?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    futureTodos = TodosDao.instance.selectAll();
    streamTodos = TodosDao.instance.selectAllStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.directions_car),
            onPressed: () {
              print('action');
            },
          ),
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {'Logout', 'Settings'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: Text('Mon profile'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Reloading')));
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Adding new todo...')));
          TodosDao.instance
              .insert("Todo title", "Todo content")
              .then((value) => setState(() {
                    futureTodos = TodosDao.instance.selectAll();
                  }));
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue[600],
      ),
      body: SingleChildScrollView(
          child: StreamBuilder<List<Todo>>(
        stream: streamTodos,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //https://pub.dev/packages/loadmore
            return ListView.builder(
              primary: false,
              itemBuilder: (BuildContext context, int index) => Card(
                child: ListTile(
                  leading:
                      /*Image.network(snapshot.data![index].avatar!,
                                    loadingBuilder: (context, child, progress) {
                              return progress != null
                                  ? child
                                  : LinearProgressIndicator();
                            })*/
                      CachedNetworkImage(
                    placeholder: (context, url) => CircularProgressIndicator(),
                    imageUrl: "https://picsum.photos/200",
                  ),
                  title: Text(snapshot.data![index].title),
                  subtitle: Text(snapshot.data![index].content),
                  trailing: PopupMenuButton<String>(
                    onSelected: (String? choice) async {
                      if (choice == 'Profile') {
                        final res = await Navigator.pushNamed(
                          context,
                          ProfileScreen.routeName,
                          arguments: snapshot.data![index],
                        );
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('$res')));
                      } else if (choice == 'Supprimer') {
                        String? res = await _showMyDialog(context);
                        if (res == "OK") {
                          TodosDao.instance
                              .deleteItem(snapshot.data![index])
                              .then((value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Supprimé !")));
                          });
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return {'Profile', 'Appeler', 'Supprimer'}
                          .map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  ),
                  //Icon(Icons.more_vert),
                  isThreeLine: true,
                ),
              ),
              itemCount: snapshot.data?.length,
              shrinkWrap: true,
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
      )),
    );
  }
}
