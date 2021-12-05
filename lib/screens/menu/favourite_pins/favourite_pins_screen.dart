import 'package:coworking/models/pin.dart';
import 'package:coworking/screens/menu/favourite_pins/favourite_pins_list.dart';
import 'package:coworking/services/database_pin.dart';
import 'package:flutter/material.dart';
import 'package:coworking/models/account.dart';

class FavouritePinsScreen extends StatelessWidget {
  const FavouritePinsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Понравившиеся места'),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            semanticLabel: "Back",
          ),
          onPressed: () => Navigator.pop(context, false),
        ),
        actions: <Widget>[
          PopupMenuButton(
            tooltip: "Help",
            icon: const Icon(
              Icons.help,
              color: Colors.black,
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                child: Text(
                  "\nЗдесь будут отображаться все места, которые вам понравились.\n"
                  "\nПо нажатию вы можете переместиться к месту.\n",
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          )
        ],
      ),
      body: const BodyLayout(),
    );
  }
}

class BodyLayout extends StatelessWidget {
  const BodyLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          DatabasePin.fetchFavouritePinsForUser(Account.currentAccount!, context),
      builder: (context, snapshot) => (snapshot.hasData)
          ? StreamBuilder<List<Pin>>(
              stream: snapshot.data as Stream<List<Pin>>?,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Pin pin = snapshot.data![index];
                        return FavouritePinsListItem(pin);
                      },
                    );
                  } else {
                    return const Center(
                      child: Text("Пока здесь пусто :( \n",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20)),
                    );
                  }
                }
              },
            )
          : Center(
              child: Column(
                children: const <Widget>[
                  Text("Загружаем данные"),
                  CircularProgressIndicator(),
                ],
              ),
            ),
    );
  }
}
