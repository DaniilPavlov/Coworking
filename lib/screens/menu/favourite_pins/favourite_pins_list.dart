// Любимые отзывы
import 'package:coworking/models/pin.dart';
import 'package:coworking/navigation/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FavouritePinsListItem extends ListTile {
  final LatLng location;
  final Pin pin;

  const FavouritePinsListItem(this.pin, this.location, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        //TODO не работает переход по локации
        onTap: () {
          print("LOCATION " + location.longitude.toString());
          Navigator.pushReplacementNamed(
              context, MainNavigationRouteNames.mapScreen,
              arguments: location);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black.withOpacity(0.2)),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ]),
          clipBehavior: Clip.hardEdge,
          child: Row(children: [
            Image.network(
              pin.imageUrl,
              width: 95,
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    pin.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    pin.rating.toString(),
                    style: const TextStyle(color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // Text(
                  //   pin.author.userName,
                  //   maxLines: 2,
                  //   overflow: TextOverflow.ellipsis,
                  // )
                ],
              ),
            ),
            const SizedBox(
              width: 10,
            )
          ]),
        ),
      ),
    );

    ///сама по себе карточка не кликабельна, поэтому добавляем инквел
    ///но оборачиваем его в матириал, чтобы был виден сплеш
    ///от нажатия
    //     Material(
    //       ///без color содержимое контейнера пропадает
    //       ///поэтому добавляем прозрачность
    //       color: Colors.transparent,
    //       child: InkWell(
    //           borderRadius: BorderRadius.circular(10),
    //           onTap: () => Navigator.pushReplacementNamed(
    //               context, MainNavigationRouteNames.mapScreen,
    //               arguments: location)),
    //     )
    //   ]),
    // );
  }

  // Padding(
  //   padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
  //   child: Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     mainAxisSize: MainAxisSize.min,
  //     children: <Widget>[
  //       Image.network(
  //         pin.imageUrl,
  //         height: 100,
  //         width: 100,
  //       ),
  //       Expanded(
  //         flex: 3,
  //         child: Text(
  //           "Место: " + pin.name,
  //           style:
  //               DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.3),
  //         ),
  //       ),
  //       IconButton(
  //         icon: const Icon(
  //           Icons.pin_drop_outlined,
  //           color: Colors.black,
  //           semanticLabel: "Go to pin",
  //         ),
  //         iconSize: 40.0,
  //         color: const Color.fromRGBO(0, 0, 0, 0.3),
  //         onPressed: () {
  //           Navigator.pushReplacementNamed(
  //               context, MainNavigationRouteNames.mapScreen,
  //               arguments: location);
  //         },
  //       ),
  //       const Spacer(),
  //       IconButton(
  //         icon: const Icon(
  //           Icons.star,
  //           semanticLabel: "Remove",
  //         ),
  //         iconSize: 30.0,
  //         onPressed: () {
  //           DatabasePin.removeFavourite(pin.id);
  //         },
  //       ),
  //     ],
  //   ),
  // );

}
