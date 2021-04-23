import 'package:coworking/resources/database.dart';
import 'package:coworking/resources/review.dart';
import 'package:flutter/material.dart';

import 'review_tile.dart';


class FlaggedCommentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text('Жалобы на отзывы'),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
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
    return StreamBuilder<List<Review>>(
      stream: Database.flaggedReviews(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.hasData && snapshot.data.length > 0) {
            return ListView.separated(
              separatorBuilder: (context, index) => Divider(
                thickness: 2,
                color: Colors.orange,
              ),
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                Review review = snapshot.data[index];
                return FlaggedReviewsListItem(review);
              },
            );
          } else {
            return Center(
              child: Text("Жалоб на отзывы нет!"),
            );
          }
        }
      },
    );
  }
}
