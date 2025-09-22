import 'package:coworking/domain/entities/account.dart';
import 'package:coworking/domain/services/database_account.dart';
import 'package:coworking/domain/services/sign_in.dart';
import 'package:coworking/navigation/main_navigation.dart';
import 'package:coworking/screens/menu/account.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  MenuDrawerState createState() => MenuDrawerState();
}

class MenuDrawerState extends State<MenuDrawer> {
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
                      (_user == null) ? 'X' : _user!.displayName!.substring(0, 1),
                    ),
                  )
                : CircleAvatar(
                    backgroundImage: NetworkImage(_user!.photoURL!),
                  ),
            accountName: Text(
              (_user == null) ? 'Username' : _user!.displayName!,
            ),
            accountEmail: Text(
              (_user == null) ? 'Email' : _user!.email!,
            ),
          ),
          ListTile(
            title: const Text('Понравившиеся места'),
            onTap: () {
              Navigator.pushNamed(context, MainNavigationRouteNames.favouriteReviews);
            },
          ),
          ListTile(
            title: const Text('Ваши отзывы'),
            onTap: () {
              Navigator.pushNamed(context, MainNavigationRouteNames.userReviews);
            },
          ),
          ListTile(
            title: const Text('Профиль'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AccountScreen())).then((value) {
                if (Account.hasUpdated != null) {
                  Account.hasUpdated!.future.then((_) {
                    setState(() {
                      _user = SignIn.auth.currentUser;
                    });
                    debugPrint(_user!.displayName);
                  });
                }
              });
            },
          ),
          FutureBuilder(
            future: DatabaseAccount.isAdmin(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListTile(
                  title: const Text('Жалобы на отзывы'),
                  onTap: () {
                    Navigator.pushNamed(context, MainNavigationRouteNames.flaggedReviews);
                  },
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }
}
