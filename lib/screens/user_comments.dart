import 'package:flutter/material.dart';
import 'package:coworking/resources/account.dart';
import 'package:coworking/resources/review.dart';
import 'package:coworking/screens/comment_tile.dart';

class UserCommentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Ваши отзывы'),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            semanticLabel: "Back",
          ),
          onPressed: () => Navigator.pop(context, false),
        ),
        actions: <Widget>[
          PopupMenuButton(
            tooltip: "Help",
            icon: Icon(
              Icons.help,
              color: Colors.black,
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                child: Text(
                  "\nЗдесь будут отображаться все отзывы, написанные Вами.\n"
                  "\nПо нажатию Вы можете переместиться к месту.\n",
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          )
        ],
      ),
      body: BodyLayout(),
    );
  }
}

class BodyLayout extends StatefulWidget {
  @override
  _BodyLayoutState createState() => _BodyLayoutState();
}

class _BodyLayoutState extends State<BodyLayout> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Review>>(
      stream: Account.getReviewsForUser(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return (snapshot.data.length > 0)
              ? ListView.separated(
                  separatorBuilder: (context, index) => Divider(
                    thickness: 2,
                    color: Colors.orange,
                  ),
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    Review review = snapshot.data.elementAt(index);
                    return YourReviewsListItem(
                      name: review.pin.name,
                      date: review.timestamp,
                      comment: review.body,
                      location: review.pin.location,
                      photoUrl: review.pin.imageUrl,
                    );
                  },
                )
              : Center(
                  child: Text("Самое время оставить свой первый отзыв!"),
                );
        }
      },
    );
  }
}
