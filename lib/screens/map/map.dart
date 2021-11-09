import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coworking/models/account.dart';
import 'package:coworking/navigation/main_navigation.dart';
import 'package:coworking/screens/login/logo_decoration.dart';
import 'package:coworking/screens/map/bottom_nav_bar.dart';
import 'package:coworking/services/database_pin.dart';
import 'package:coworking/models/pin.dart';
import 'package:coworking/screens/map/pin/pin_widget.dart';
import 'package:coworking/screens/meetings/meetings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';

import 'package:coworking/screens/menu/menu_drawer.dart';
import 'package:coworking/screens/map/pin/create_pin.dart';

class MapPage extends StatefulWidget {
  static const kDefaultZoom = 10.0;
  final CameraPosition? currentMapPosition;

//TODO тут всегда нул, разобраться
  MapPage({Key? key, LatLng? currentMapPosition})
      : currentMapPosition = (currentMapPosition == null)
            ? null
            : CameraPosition(target: currentMapPosition, zoom: kDefaultZoom),
        super(key: key);

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  //используется для анимации состояния перехода нового пина
  late AnimationController drawerAnimator;
  late bool showDrawer;
  final double drawerHeight = 300;

  // насколько карта закрыта нижней панелью
  late EdgeInsets mapOverlap;
  late CameraPosition currentMapPosition;

  Set<Pin> pins = <Pin>{};

  late GlobalKey<CreatePinState> pinFormKey;

  late FloatingActionButton fabAddPin;
  late FloatingActionButton fabConfirmPin;
  late FloatingActionButton currentFab;

  // открывыем дроуер снизу вверх, для центральной круглой кнопки
  void openDrawer() {
    setState(() {
      drawerAnimator.forward();
      showDrawer = true;
      currentFab = fabConfirmPin;
    });
  }

  // закрываем дроуер
  void closeDrawer() async {
    await drawerAnimator.reverse();
    setState(() {
      showDrawer = false;
      currentFab = fabAddPin;
    });
  }

  // ОТКРЫВАЕМ ИНФОРМАЦИЮ О ПИНЕ
  void updateMapPosition(Pin pin) {
    CameraPosition newPosition =
        CameraPosition(target: pin.location, zoom: MapPage.kDefaultZoom);
    setState(() {
      currentMapPosition = newPosition;
    });

    Navigator.of(context)
        .pushNamed(MainNavigationRouteNames.pinDetails, arguments: pin);
  }

  void barHeightChange(double height) {
    setState(() {
      mapOverlap =
          MediaQuery.of(context).padding + EdgeInsets.only(bottom: height);
    });
  }

  late StreamSubscription<List<PinChange>> pinsStream;

  ///кажется что стрим работает стабильно
  void queryPins() {
    pinsStream = DatabasePin.getPins(context).listen((pinChangesList) {
      setState(() {
        for (PinChange pinChange in pinChangesList) {
          if (pinChange.type == DocumentChangeType.added) {
            print("БЫЛ ДОБАВЛЕН МАРКЕР");
            pins.add(pinChange.pin);
            MapBodyState.markers.add(pinChange.pin.marker!);
          } else if (pinChange.type == DocumentChangeType.removed) {
            print("1 ИЗ МАРКЕРОВ БЫЛ УДАЛЕН");
            MapBodyState.markers.remove(pinChange.pin.marker);
            pins.remove(pinChange.pin);
            print(pinChange.pin.name);
          } else if (pinChange.type == DocumentChangeType.modified) {
            print("1 ИЗ МАРКЕРОВ БЫЛ ИЗМЕНЕН");
            for (var element in pins) {
              if (element.author.toString() ==
                      pinChange.pin.author.toString() &&
                  element.name.toString() == pinChange.pin.name.toString() &&
                  element.imageUrl.toString() ==
                      pinChange.pin.imageUrl.toString() &&
                  element.category.toString() ==
                      pinChange.pin.category.toString() &&
                  element.marker != pinChange.pin.marker) {
                element.marker = pinChange.pin.marker;
              }
            }
            print(pinChange.pin.name);
          }
        }
      });
    });
  }

  Position currentPosition = const Position(
      longitude: 30.359357,
      latitude: 69.933895,
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      timestamp: null);

  bool locationEnabled = false;

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    LocationPermission permission;

    // Test if location services are enabled.
    locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print("LONG" + currentPosition.latitude.toString());
    setState(() {
      currentPosition;
    });
    currentMapPosition = CameraPosition(
        target: LatLng(currentPosition.latitude, currentPosition.longitude),
        zoom: MapPage.kDefaultZoom);
    return currentPosition;
  }

  Future? getLocation;

  @override
  void initState() {
    super.initState();
    drawerAnimator = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    showDrawer = false;
    mapOverlap = EdgeInsets.zero;

    currentMapPosition = CameraPosition(
        target: LatLng(currentPosition.latitude, currentPosition.longitude),
        zoom: MapPage.kDefaultZoom);

    getLocation = _determinePosition();
    pinFormKey = GlobalKey<CreatePinState>();

    fabAddPin = FloatingActionButton(
      tooltip: "Add pin",
      onPressed: openDrawer,
      child: const Icon(Icons.add_location),
    );

    fabConfirmPin = FloatingActionButton(
      tooltip: "Confirm",
      onPressed: () {
        if (pinFormKey.currentState!.validate()) {
          pinFormKey.currentState!.createPin().then((pin) {
            pins.add(pin);
            DatabasePin.addVisited(Account.currentAccount!.id!, pin.id);
          });
          closeDrawer();
        }
      },
      child: const Icon(Icons.check),
      backgroundColor: Colors.green,
    );

    currentFab = fabAddPin;

    queryPins();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onLaunch: $message");
      Navigator.of(context).pushNamed(MainNavigationRouteNames.meetingsScreen);
    });
  }

  ///WIDGET BUILD
  @override
  Widget build(BuildContext context) {
    print("REBUILD " + currentPosition.longitude.toString());
    return FutureBuilder(
        future: getLocation,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return WillPopScope(
              onWillPop: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                            title: const Text(
                              "Вы действительно хотите выйти?",
                              style: TextStyle(color: Colors.orange),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                  child: const Text(
                                    "Да",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.orange),
                                  ),
                                  onPressed: () {
                                    exit(0);
                                  }),
                              const SizedBox(
                                width: 100,
                              ),
                              TextButton(
                                child: const Text("Нет",
                                    style: TextStyle(color: Colors.white)),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.orange),
                                ),
                                onPressed: () => Navigator.pop(context, false),
                              ),
                            ]));
                return true as Future<bool>;
              },
              child: Scaffold(
                body: MapBody(
                  mapMoveCallback: (value) => currentMapPosition = value,
                  initialPosition: currentMapPosition,
                  locationEnabled: locationEnabled,
                  mapOverlap: mapOverlap,
                  drawerHeight: drawerHeight,
                  pins: pins,
                  pinAnimation: drawerAnimator,
                  pinsStream: pinsStream,
                ),
                drawer: const MenuDrawer(),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButton: currentFab,
                resizeToAvoidBottomInset: false,
                // сделанно для того, чтобы при открытии клавиатуры карта не изменяла размер
                extendBody: true,
                // сверху над картой помещаем боттом нав бар
                bottomNavigationBar: BottomBar(
                  pinFormKey,
                  closeDrawer,
                  mapOverlap == EdgeInsets.zero ? barHeightChange : (_) {},
                  drawerHeight,
                  drawerAnimator,
                  showDrawer,
                  updateMapPosition,
                ),
              ),
            );
          } else {
            return const LogoDecoration(
              child: Center(child: CircularProgressIndicator()),
            );
          }
        });
  }

  @override
  void dispose() {
    drawerAnimator.dispose();
    super.dispose();
  }
}

class MapBody extends StatefulWidget {
  MapBody({
    Key? key,
    required this.mapMoveCallback,
    required this.initialPosition,
    required this.locationEnabled,
    required this.mapOverlap,
    required this.drawerHeight,
    required this.pins,
    required this.pinAnimation,
    required this.pinsStream,
  }) : super(key: key);

  final Function(CameraPosition) mapMoveCallback;
  final CameraPosition initialPosition;
  final bool locationEnabled;
  final EdgeInsets mapOverlap;
  final double drawerHeight;

  late Set<Pin> pins;

  final Animation<double> pinAnimation;
  final StreamSubscription<List<PinChange>> pinsStream;

  @override
  State<MapBody> createState() => MapBodyState();
}

class MapBodyState extends State<MapBody> with WidgetsBindingObserver {
  // Обновляем карту и определяем пермишены. Однако, если человек установил
  // режим больше не спрашивать - не спросим
  // void monitorLocationPerm() async {
  //   ServiceStatus? currentServiceStatus, oldServiceStatus;

  //   while (true) {
  //     oldServiceStatus = currentServiceStatus;
  //     currentServiceStatus = (await Permission.location.serviceStatus);

  //     // проверяем пермишены только если изменился статус сервиса
  //     if (currentServiceStatus == oldServiceStatus) continue;

  //     // если джипиэс выключен - локация недоступна
  //     // кнопка *наведись на нас* пропадает
  //     if (currentServiceStatus == ServiceStatus.disabled) {
  //       setState(() {
  //         locationEnabled = false;
  //       });
  //       continue;
  //     }

  //     // джипиэс включили, проверяем разрешения
  //     PermissionStatus permissionStatus = await Permission.location.status;

  //     if (permissionStatus == PermissionStatus.denied ||
  //         permissionStatus == PermissionStatus.permanentlyDenied) {
  //       permissionStatus = (await Permission.location.request());
  //     }

  //     setState(() {
  //       if (permissionStatus == PermissionStatus.denied ||
  //           permissionStatus == PermissionStatus.permanentlyDenied) {
  //         locationEnabled = false;
  //       } else if (permissionStatus == PermissionStatus.granted) {
  //         locationEnabled = true;
  //       }
  //     });
  //   }
  // }

  //начальное состояние, проверяем пермишены
  @override
  void initState() {
    super.initState();
    // monitorLocationPerm();
    WidgetsBinding.instance!.addObserver(this);
  }

  //отписываемся от стрима с пинами
  @override
  void dispose() {
    print("DISPOSE PINS STREAM");
    widget.pinsStream.cancel();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  static Set<Marker> markers = <Marker>{};

  //добавляем пины на карту
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.pinAnimation,

          ///Была ошибка с жестом 3 пальцев, добавил ListView с itemExtent
          builder: (context, _) => ListView(
              itemExtent: MediaQuery.of(context).size.height -
                  widget.mapOverlap.bottom +
                  20,
              children: <Widget>[
                GoogleMap(
                  initialCameraPosition: widget.initialPosition,

                  padding: widget.mapOverlap +
                      EdgeInsets.only(
                          bottom:
                              widget.drawerHeight * widget.pinAnimation.value),
                  // поднимаем +- и надпись гугл
                  markers: markers,
                  myLocationEnabled: widget.locationEnabled,
                  myLocationButtonEnabled: widget.locationEnabled,
                  onCameraMove: widget.mapMoveCallback,
                  gestureRecognizers: {}
                    ..add(Factory<PanGestureRecognizer>(
                        () => PanGestureRecognizer()))
                    ..add(Factory<ScaleGestureRecognizer>(
                        () => ScaleGestureRecognizer()))
                    ..add(Factory<TapGestureRecognizer>(
                        () => TapGestureRecognizer()))
                    ..add(Factory<VerticalDragGestureRecognizer>(
                        () => VerticalDragGestureRecognizer())),
                )
              ]),
        ),
        Align(
          child: Transform.translate(
            // настройка положения пина
            offset: Offset(
              0.0,
              (widget.mapOverlap.top -
                      widget.drawerHeight -
                      widget.mapOverlap.bottom +
                      20) /
                  2,
            ),

            //тут наводимся куда поставить наш пин
            child: ScaleTransition(
              scale: widget.pinAnimation, // масштабирование пина
              child: const FractionalTranslation(
                translation: Offset(0.0, -0.5), // корректируем пин в центр
                child: Icon(
                  Icons.location_on,
                  size: 48.0,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
