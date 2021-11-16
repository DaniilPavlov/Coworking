import 'package:coworking/models/review.dart';
import 'package:coworking/services/database_review.dart';
import 'package:coworking/utils/format_date.dart';
import 'package:flutter/material.dart';

class FlaggedReviewsListItem extends ListTile {
  const FlaggedReviewsListItem(this.review, {Key? key}) : super(key: key);

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: _ReviewBody(
              name: review.pin!.name,
              date: review.timestamp,
              comment: review.body,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.check_circle,
              color: Colors.green,
              semanticLabel: "Allow",
            ),
            iconSize: 40.0,
            color: Colors.grey[600],
            onPressed: () {
              DatabaseReview.justifyFlag(review.id!);
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.delete,
              semanticLabel: "Delete",
            ),
            iconSize: 40.0,
            color: Colors.red,
            onPressed: () {
              DatabaseReview.deleteReview(review);
            },
          ),
        ],
      ),
    );
  }
}

class _ReviewBody extends ListTile {
  // ignore: annotate_overrides, overridden_fields
  final bool enabled = true;
  final String name;
  final DateTime date;
  final String comment;

  const _ReviewBody({
    Key? key,
    required this.name,
    required this.date,
    required this.comment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Место: " + name,
              style:
                  DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.3),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(width: 200, child: Text("Отзыв: " + comment)),
            Text(
              FormatDate.formatDate(date),
              style: TextStyle(color: Colors.black.withOpacity(0.4)),
            ),
          ]),
    );
  }
}
