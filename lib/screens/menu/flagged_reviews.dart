import 'package:coworking/models/review.dart';
import 'package:coworking/services/database_review.dart';
import 'package:flutter/material.dart';

import 'package:coworking/screens/menu/review_tile.dart';

class FlaggedReviewsScreen extends StatelessWidget {
  const FlaggedReviewsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text('Жалобы на отзывы'),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              semanticLabel: "Back",
            ),
            onPressed: () => Navigator.pop(context, false),
          )),
      body: const BodyLayout(),
    );
  }
}

class BodyLayout extends StatelessWidget {
  const BodyLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Review?>>(
      stream: DatabaseReview.flaggedReviews(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.hasData) {
            return ListView.separated(
              separatorBuilder: (context, index) => const Divider(
                thickness: 2,
                color: Colors.orange,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Review review = snapshot.data![index]!;
                return FlaggedReviewsListItem(review);
              },
            );
          } else {
            return const Center(
              child: Text("Жалоб на отзывы нет!"),
            );
          }
        }
      },
    );
  }
}
