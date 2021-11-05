import 'package:coworking/models/account.dart';
import 'package:coworking/services/database_map.dart';
import 'package:coworking/screens/menu/starred_reviews.dart';
import 'package:coworking/screens/menu/user_reviews.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:coworking/services/sign_in.dart';
import 'package:coworking/screens/menu/account.dart';
import 'package:coworking/screens/menu/flagged_reviews.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({Key? key}) : super(key: key);

  @override
  _MenuDrawerState createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  late User? _user;

  @override
  void initState() {
    super.initState();
    setState(() {
      _user = SignIn.auth.currentUser;
    });
  }

  ///Кнопка меню
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            currentAccountPicture: (_user == null || _user!.photoURL == null)
                ? CircleAvatar(
                    child: Text(
                      (_user == null)
                          ? "X"
                          : _user!.displayName!.substring(0, 1),
                    ),
                  )
                : CircleAvatar(
                    backgroundImage: NetworkImage(_user!.photoURL!),
                  ),
            accountName: Text(
              (_user == null) ? "Username" : _user!.displayName!,
            ),
            accountEmail: Text(
              (_user == null) ? "Email" : _user!.email! ,
            ),
          ),
          ListTile(
            title: const Text("Понравившиеся отзывы"),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StarredCommentsPage()));
            },
          ),
          ListTile(
            title: const Text("Ваши отзывы"),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserCommentsPage()));
            },
          ),
          ListTile(
            title: const Text("Профиль"),
            onTap: () {
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AccountPage()))
                  .then((value) {
                if (Account.hasUpdated != null) {
                  Account.hasUpdated!.future.then((_) {
                    setState(() {
                      _user = SignIn.auth.currentUser;
                    });
                    print(_user!.displayName);
                  });
                }
              });
            },
          ),
          FutureBuilder(
              future: DatabaseMap.isAdmin(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListTile(
                    title: const Text("Жалобы на отзывы"),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FlaggedCommentsPage()));
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
        ],
      ),
    );
  }
}
