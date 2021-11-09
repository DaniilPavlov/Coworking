import 'package:coworking/services/database_review.dart';
import 'package:flutter/material.dart';
import 'package:coworking/models/account.dart';
import 'package:coworking/models/review.dart';
import 'package:coworking/screens/menu/review_tile.dart';

class UserCommentsPage extends StatelessWidget {
  const UserCommentsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Ваши отзывы'),
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
                  "\nЗдесь будут отображаться все отзывы, написанные Вами.\n"
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

class BodyLayout extends StatefulWidget {
  const BodyLayout({Key? key}) : super(key: key);

  @override
  _BodyLayoutState createState() => _BodyLayoutState();
}

class _BodyLayoutState extends State<BodyLayout> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Review>>(
      stream: DatabaseReview.reviewsOfUser(Account.currentAccount!, context),
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return (snapshot.data!.isNotEmpty)
              ? ListView.separated(
                  separatorBuilder: (context, index) => const Divider(
                    thickness: 2,
                    color: Colors.orange,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Review review = snapshot.data!.elementAt(index);
                    return YourReviewsListItem(
                      name: review.pin!.name,
                      date: review.timestamp,
                      comment: review.body,
                      location: review.pin!.location,
                      photoUrl: review.pin!.imageUrl,
                    );
                  },
                )
              : const Center(
                  child: Text("Самое время оставить свой первый отзыв!"),
                );
        }
      },
    );
  }
}
