import 'package:coworking/resources/pin.dart';
import 'package:edit_distance/edit_distance.dart';
import 'package:flutter/material.dart';


class MapSearchDelegate extends SearchDelegate<Pin> {
  final Levenshtein distance = Levenshtein();
  final Set<Pin> pins;

  MapSearchDelegate(this.pins);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(
          Icons.clear,
          semanticLabel: "Clear",
        ),
        onPressed: () {
          query = ''; // reset query on clear
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return BackButton(); // button before search query
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Pin> results = List<Pin>();

    for (Pin pin in pins) {
      /* a much better algorithm would look for terms in the query separately
       * using a fuzzy-match and rank results based on how close they are to terms.
       */
      // if pin's name contains query, add as result
      if (pin.name.contains(RegExp(query, caseSensitive: false))) {
        results.add(pin);
      }

      //Find pin by id
      try {
        if (pin.id.hashCode == int.parse(query)) {
          results.add(pin);
        }
      } catch (e) {}
    }

    return ListView.separated(
      padding: EdgeInsets.all(8),
      itemCount: results.length,
      itemBuilder: (context, i) {
        return GestureDetector(
          onTap: () {
            this.close(context, results[i]);
          },
          child: Container(
            height: 50,
            child: Align(
              child: Text(
                results[i].name,
                textScaleFactor: 1.2,
              ),
              alignment: Alignment.centerLeft,
            ),
          ),
        );
      },
      separatorBuilder: (context, i) {
        return Divider();
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Pin> suggestions = List<Pin>();

    for (Pin pin in pins) {
      /* a much better algorithm would look for terms in the query separately
       * using a fuzzy-match and rank results based on how close they are to terms.
       */
      // if pin's name contains query, add as result
      if (pin.name.contains(RegExp(query, caseSensitive: false)) ||
          distance.distance(pin.name, query) < 4) {
        suggestions.add(pin);
      }
    }
    return Column(); // TODO: add suggestions
  }
}
