import 'package:flutter/material.dart';
import 'package:coworking/models/account.dart';
import 'package:coworking/models/review.dart';
import 'package:coworking/screens/menu/review_tile.dart';

class StarredCommentsPage extends StatelessWidget {
  const StarredCommentsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Понравившиеся отзывы'),
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
                  "\nЗдесь будут отображаться все отзывы, которые Вам понравились.\n"
                  "\nПо нажатию Вы можете переместиться к месту.\n",
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
      future: Account.getFavouriteReviewsForUser(context),
      builder: (context, snapshot) => (snapshot.hasData)
          ? StreamBuilder<List<Review>>(
              stream: snapshot.data as  Stream<List<Review>>?,
              builder: (context, snapshot) {
                //пока ждем прогрузы отзывов крутим спин загрузки
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return ListView.separated(
                      separatorBuilder: (context, index) => const Divider(
                        color: Colors.orange,
                        thickness: 2,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Review review = snapshot.data![index];
                        return StarredReviewsListItem(
                            review, review.pin!.location);
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
