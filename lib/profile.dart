import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/material.dart';
import 'models.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    // Extract the arguments from the current ModalRoute
    // settings and cast them as ScreenArguments.
    final user = ModalRoute.of(context)!.settings.arguments as User;
    return new WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text("${user.first_name} ${user.last_name}"),
            leading: new IconButton(
              icon: new Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context, "${user.first_name} ${user.last_name}");
              },
            ),
          ),
          body: Center(
            child: CachedNetworkImage(
              placeholder: (context, url) => CircularProgressIndicator(),
              imageUrl: user.avatar!,
            ),
          ),
        ),
        onWillPop: () async {
          Navigator.pop(context, "${user.first_name} ${user.last_name}");
          //return false; // block to this screen
          return true;
        });
  }
}
