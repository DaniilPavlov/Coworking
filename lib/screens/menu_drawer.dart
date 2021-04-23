import 'package:coworking/resources/account.dart';
import 'package:coworking/resources/database.dart';
import 'package:coworking/screens/starred_reviews.dart';
import 'package:coworking/screens/user_reviews.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../sign_in.dart';
import 'account.dart';
import 'flagged_reviews.dart';

class MenuDrawer extends StatefulWidget {
  @override
  _MenuDrawerState createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  FirebaseUser _user;

  @override
  void initState() {
    SignIn.auth.currentUser().then((user) {
      setState(() {
        _user = user;
      });
    });
    super.initState();
  }

  ///Кнопка меню
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            currentAccountPicture: (_user == null || _user.photoUrl == null)
                ? CircleAvatar(
                    child: Text(
                      (_user == null) ? "X" : _user.displayName.substring(0, 1),
                    ),
                  )
                : CircleAvatar(
                    backgroundImage: NetworkImage(_user.photoUrl),
                  ),
            accountName: Text(
              (_user == null) ? "Username" : _user.displayName,
            ),
            accountEmail: Text(
              (_user == null) ? "Email" : _user.email,
            ),
          ),
          ListTile(
            title: Text("Понравившиеся отзывы"),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StarredCommentsPage()));
            },
          ),
          ListTile(
            title: Text("Ваши отзывы"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UserCommentsPage()));
            },
          ),
          ListTile(
            title: Text("Профиль"),
            onTap: () {
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AccountPage()))
                  .then((value) {
                if (Account.hasUpdated != null) {
                  Account.hasUpdated.future.then((_) {
                    FirebaseAuth.instance.currentUser().then((user) {
                      setState(() {
                        _user = user;
                      });
                      print(user.displayName);
                    });
                  });
                }
              });
            },
          ),
          FutureBuilder(
              future: Database.isAdmin(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return (snapshot.data)
                      ? ListTile(
                          title: Text("Жалобы на отзывы"),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        FlaggedCommentsPage()));
                          },
                        )
                      : Container();
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
        ],
      ),
    );
  }
}
