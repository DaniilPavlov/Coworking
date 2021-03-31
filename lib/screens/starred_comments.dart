import 'package:flutter/material.dart';
import 'package:coworking/resources/account.dart';
import 'package:coworking/resources/review.dart';
import 'package:coworking/screens/comment_tile.dart';

class StarredCommentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text('Понравившиеся отзывы'),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              semanticLabel: "Back",
            ),
            onPressed: () => Navigator.pop(context, false),
          )),
      body: BodyLayout(),
    );
  }
}

class BodyLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Account.getFavouriteReviewsForUser(context),
      builder: (context, snapshot) => (snapshot.hasData)
          ? StreamBuilder<List<Review>>(
              stream: snapshot.data,
              builder: (context, snapshot) {
                ///пока ждем прогрузы отзывов крутим спин загрузки
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (snapshot.hasData && snapshot.data.length > 0) {
                    return ListView.separated(
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.orange,
                        thickness: 2,
                      ),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        Review review = snapshot.data[index];
                        return StarredReviewsListItem(review);
                      },
                    );
                  } else {
                    return Center(
                      child: Text("Пока здесь пусто :( \n",textAlign: TextAlign.center,style: TextStyle(fontSize:20)),
                    );
                  }
                }
              },
            )
          : Center(
              child: Column(
                children: <Widget>[
                  Text("Загружаем данные"),
                  CircularProgressIndicator(),
                ],
              ),
            ),
    );
  }
}
