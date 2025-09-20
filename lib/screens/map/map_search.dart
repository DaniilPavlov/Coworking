import 'package:coworking/domain/entities/pin.dart';
import 'package:edit_distance/edit_distance.dart';
import 'package:flutter/material.dart';

class MapSearchDelegate extends SearchDelegate<Pin> {
  MapSearchDelegate(this.pins);
  final Levenshtein distance = Levenshtein();
  final Set<Pin> pins;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      //очистка строки запроса
      IconButton(
        icon: const Icon(
          Icons.clear,
          semanticLabel: 'Clear',
        ),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return const BackButton();
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Pin> results = <Pin>[];
    for (Pin pin in pins) {
      if (pin.name.contains(RegExp(query, caseSensitive: false))) {
        results.add(pin);
      }
      try {
        if (pin.id.hashCode == int.parse(query)) {
          results.add(pin);
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: results.length,
      itemBuilder: (context, i) {
        return GestureDetector(
          onTap: () {
            close(context, results[i]);
          },
          child: SizedBox(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                results[i].name,
                textScaler: const TextScaler.linear(1.2),
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, i) {
        return const Divider();
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Pin> suggestions = <Pin>[];

    for (Pin pin in pins) {
      // если в названии пина есть заданный набор букв - выводим
      if (pin.name.contains(RegExp(query, caseSensitive: false)) || distance.distance(pin.name, query) < 4) {
        suggestions.add(pin);
      }
    }
    return const Column();
  }
}
