import 'package:coworking/models/pin.dart';
import 'package:edit_distance/edit_distance.dart';
import 'package:flutter/material.dart';

//TODO НУЖНО ДОБАВИТЬ ФИЛЬТР (ПО КАТЕГОРИЯМ МЕСТ)
class MapSearchDelegate extends SearchDelegate<Pin> {
  final Levenshtein distance = Levenshtein();
  final Set<Pin> pins;

  MapSearchDelegate(this.pins);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      //очистка строки запроса
      IconButton(
        icon: Icon(
          Icons.clear,
          semanticLabel: "Clear",
        ),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return BackButton();
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Pin> results = List<Pin>();
    for (Pin pin in pins) {
      if (pin.name.contains(RegExp(query, caseSensitive: false))) {
        results.add(pin);
      }
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
      // если в названии пина есть заданный набор букв - выводим
      if (pin.name.contains(RegExp(query, caseSensitive: false)) ||
          distance.distance(pin.name, query) < 4) {
        suggestions.add(pin);
      }
    }
    return Column(); // TODO: добавить suggestions
  }
}
