import 'package:coworking/domain/entities/review.dart';
import 'package:coworking/screens/menu/user_reviews/user_reviews_list.dart';
import 'package:coworking/domain/services/database_review.dart';
import 'package:flutter/material.dart';
import 'package:coworking/domain/entities/account.dart';

class UserReviewsScreen extends StatelessWidget {
  const UserReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Ваши отзывы'),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            semanticLabel: 'Back',
          ),
          onPressed: () => Navigator.pop(context, false),
        ),
        actions: <Widget>[
          PopupMenuButton(
            tooltip: 'Help',
            icon: const Icon(
              Icons.help,
              color: Colors.black,
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                child: Text(
                  '\nЗдесь будут отображаться все отзывы, написанные Вами.\n'
                  '\nПо нажатию Вы можете переместиться к месту.\n',
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ],
      ),
      body: const BodyLayout(),
    );
  }
}

class BodyLayout extends StatelessWidget {
  const BodyLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Review>>(
      stream: DatabaseReview.fetchReviewsOfUser(Account.currentAccount!, context),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Review review = snapshot.data![index];
                return UserReviewsListItem(review);
              },
            );
          } else {
            return const Center(
              child: Text('Пока здесь пусто :( \n', textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
            );
          }
        }
      },
    );
  }
}
