import 'package:coworking/domain/entities/pin.dart';
import 'package:coworking/navigation/main_navigation.dart';
import 'package:flutter/material.dart';

class FavouritePinsListItem extends ListTile {
  const FavouritePinsListItem(this.pin, {super.key});
  final Pin pin;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            MainNavigationRouteNames.pinDetails,
            arguments: pin,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
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
                  pin.imageUrl,
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        pin.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        pin.rating.toStringAsFixed(2),
                        style: const TextStyle(color: Colors.blueAccent),
                        overflow: TextOverflow.ellipsis,
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
