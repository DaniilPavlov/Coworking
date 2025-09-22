import 'package:coworking/domain/entities/review.dart';
import 'package:coworking/navigation/main_navigation.dart';
import 'package:coworking/utils/format_date.dart';
import 'package:flutter/material.dart';

class UserReviewsListItem extends ListTile {
  const UserReviewsListItem(this.review, {super.key});
  final Review review;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, MainNavigationRouteNames.pinDetails, arguments: review.pin);
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              // border: Border.all(color: Colors.black.withOpacity(0.2)),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: Row(
              children: [
                Image.network(
                  review.pin!.imageUrl,
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        review.pin!.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.black),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
                        child: Text(
                          review.body,
                          textAlign: TextAlign.justify,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Text(
                          review.userRate.toStringAsFixed(2),
                          style: const TextStyle(color: Colors.blueAccent),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        FormatDate.formatDate(review.timestamp),
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_right_sharp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
