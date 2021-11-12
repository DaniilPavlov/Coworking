import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coworking/models/account.dart';
import 'package:coworking/navigation/main_navigation.dart';
import 'package:coworking/screens/login/logo_decoration.dart';
import 'package:coworking/screens/map/bottom_nav_bar.dart';
import 'package:coworking/services/location_status.dart';
import 'package:coworking/services/database_pin.dart';
import 'package:coworking/models/pin.dart';
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

GoogleMapController? mapController;

late StreamSubscription<List<PinChange>> pinsStream;

late StreamSubscription<ServiceStatus> locationStream;
late AnimationController drawerAnimator;

const double drawerHeight = 315;

class MapScreen extends StatefulWidget {
  static const kDefaultZoom = 10.0;
  final CameraPosition? currentMapPosition;

  MapScreen({Key? key, LatLng? currentMapPosition})
      : currentMapPosition = (currentMapPosition == null)
            ? null
            : CameraPosition(target: currentMapPosition, zoom: kDefaultZoom),
        super(key: key);

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  //используется для анимации состояния перехода нового пина

  bool showDrawer = false;

  // насколько карта закрыта нижней панелью
  EdgeInsets mapOverlap = EdgeInsets.zero;
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

  // открываем пин из серча
  void openPinFromSearch(Pin pin) {
    currentMapPosition =
        CameraPosition(target: pin.location, zoom: MapScreen.kDefaultZoom);
    mapController!
        .moveCamera(CameraUpdate.newCameraPosition(currentMapPosition));
    Navigator.of(context)
        .pushNamed(MainNavigationRouteNames.pinDetails, arguments: pin);
  }

  void barHeightChange(double height) {
    setState(() {
      mapOverlap =
          MediaQuery.of(context).padding + EdgeInsets.only(bottom: height);
    });
  }

//TODO разобраться с тостом, говорящем что нет соединения
  void watchLocationStatus() {
    locationStream = Geolocator.getServiceStatusStream()
        .listen((ServiceStatus status) async {
      await LocationStatus.checkLocationPermission();

      if (LocationStatus.locationEnabled) {
        while (mapController == null) {}
        currentMapPosition = CameraPosition(
            target: LatLng(LocationStatus.currentPosition.latitude,
                LocationStatus.currentPosition.longitude),
            zoom: MapScreen.kDefaultZoom);
        mapController!
            .moveCamera(CameraUpdate.newCameraPosition(currentMapPosition));
      }
    });
  }

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

  Future? getLocation;

  @override
  void initState() {
    super.initState();
    drawerAnimator = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

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

    getLocation = LocationStatus.checkLocationPermission();

    watchLocationStatus();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onLaunch: $message");
      Navigator.of(context).pushNamed(MainNavigationRouteNames.meetingsScreen);
    });
    currentMapPosition = CameraPosition(
        target: LatLng(LocationStatus.currentPosition.latitude,
            LocationStatus.currentPosition.longitude),
        zoom: MapScreen.kDefaultZoom);
  }

  void shouldMoveLocation() {
    if (LocationStatus.locationEnabled &&
        LocationStatus.isMapControllerConnected == false &&
        mapController != null) {
      LocationStatus.isMapControllerConnected =
          !LocationStatus.isMapControllerConnected;
      currentMapPosition = CameraPosition(
          target: LatLng(LocationStatus.currentPosition.latitude,
              LocationStatus.currentPosition.longitude),
          zoom: MapScreen.kDefaultZoom);
      mapController!
          .moveCamera(CameraUpdate.newCameraPosition(currentMapPosition));
    }
  }

  @override
  Widget build(BuildContext context) {
    shouldMoveLocation();
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
                  mapOverlap: mapOverlap,
                ),
                drawer: const MenuDrawer(),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButton: currentFab,
                resizeToAvoidBottomInset: false,
                // сделанно для того, чтобы при открытии клавиатуры карта не изменяла размер
                extendBody: true,
                // сверху над картой помещаем боттом бар
                bottomNavigationBar: BottomBar(
                  pinFormKey,
                  closeDrawer,
                  mapOverlap == EdgeInsets.zero ? barHeightChange : (_) {},
                  drawerHeight,
                  drawerAnimator,
                  showDrawer,
                  openPinFromSearch,
                ),
              ),
            );
          } else {
            return const Scaffold(
                body: LogoDecoration(
              child: Center(child: CircularProgressIndicator()),
            ));
          }
        });
  }

  @override
  void dispose() {
    drawerAnimator.dispose();
    print("DISPOSE LOCATION STREAM");
    locationStream.cancel();
    pinsStream.cancel();
    LocationStatus.locationEnabled = false;
    LocationStatus.isStarted = false;
    LocationStatus.isMapControllerConnected = false;
    LocationStatus.locationStatusChanged = false;
    super.dispose();
  }
}

class MapBody extends StatefulWidget {
  MapBody({
    Key? key,
    required this.mapMoveCallback,
    required this.initialPosition,
    required this.mapOverlap,
  }) : super(key: key);

  final Function(CameraPosition) mapMoveCallback;
  final CameraPosition initialPosition;
  final EdgeInsets mapOverlap;

  @override
  State<MapBody> createState() => MapBodyState();
}

class MapBodyState extends State<MapBody> {
  //отписываемся от стрима с пинами
  @override
  void dispose() {
    print("DISPOSE MapController");
    mapController!.dispose();
    markers.clear();
    super.dispose();
  }

  final Animation<double> pinAnimation = drawerAnimator;
  static Set<Marker> markers = <Marker>{};

  onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  //добавляем пины на карту
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedBuilder(
          animation: pinAnimation,

          ///Была ошибка с жестом 3 пальцев, добавил ListView с itemExtent
          builder: (context, _) => ListView(
              itemExtent: MediaQuery.of(context).size.height -
                  widget.mapOverlap.bottom +
                  20,
              children: <Widget>[
                GoogleMap(
                  initialCameraPosition: widget.initialPosition,
                  onMapCreated: onMapCreated,
                  padding: widget.mapOverlap +
                      EdgeInsets.only(
                          bottom: drawerHeight * pinAnimation.value),
                  // поднимаем +- и надпись гугл
                  markers: markers,
                  myLocationEnabled: LocationStatus.locationEnabled,
                  myLocationButtonEnabled: LocationStatus.locationEnabled,
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
                      drawerHeight -
                      widget.mapOverlap.bottom +
                      20) /
                  2,
            ),

            //тут наводимся куда поставить наш пин
            child: ScaleTransition(
              scale: pinAnimation, // масштабирование пина
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
