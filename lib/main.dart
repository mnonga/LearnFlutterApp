import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'models.dart';
import 'profile.dart';
import 'todo.dart';

import 'package:get_it/get_it.dart';

void main() {
  //GetIt.instance.registerSingleton<AppModel>(AppModel());
  //var myAppModel = GetIt.instance.get<AppModel>();
  //var myAppModel = GetIt.instance<AppModel>();
  runApp(MyApp());
}

//"C:\Users\michee\AppData\Local\Android\Sdk\platform-tools\adb.exe" connect localhost:62001
//https://pub.dev/packages/get_it

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Wikipedia search API'),
      routes: {
        ProfileScreen.routeName: (context) => const ProfileScreen(),
        TodoScreen.routeName: (context) =>
            const TodoScreen(title: "Todos title"),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<User>> futureUsers;
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
    futureUsers = fetchUsers();
  }

  Future<List<User>> fetchUsers() async {
    final response =
        await http.get(Uri.parse('https://reqres.in/api/users?page=$page'));

    if (response.statusCode == 200) {
      page++;
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Map<String, dynamic> json = jsonDecode(response.body);
      List<dynamic> resultList = json['data'];
      if (page > json["total_pages"]) page = 1;
      List<User> users = resultList
          .map((dynamic value) => User.fromJson(value))
          .toList(growable: false);

      return users;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load users');
    }
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
              title: Text('Todos'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  TodoScreen.routeName,
                );
              },
            ),
            ListTile(
              title: Text('Mon profile'),
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
              .showSnackBar(SnackBar(content: Text('Reloading...')));
          setState(() {
            futureUsers = fetchUsers();
          });
        },
        child: const Icon(Icons.navigation),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
          child: FutureBuilder<List<User>>(
        future: futureUsers,
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
                    imageUrl: snapshot.data![index].avatar!,
                  ),
                  title: Text(snapshot.data![index].first_name!),
                  subtitle: Text(
                      'A sufficiently long subtitle warrants three lines.'),
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
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(res!)));
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
