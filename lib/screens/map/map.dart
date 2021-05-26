import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coworking/models/account.dart';
import 'package:coworking/services/database_map.dart';
import 'package:coworking/models/pin.dart';
import 'package:coworking/screens/map/pin_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coworking/screens/meetings/meetings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/sign_in.dart';
import '../menu/menu_drawer.dart';
import '../map_search.dart';
import 'create_pin.dart';

class MapPage extends StatefulWidget {
  static const kDefaultZoom = 10.0;
  final CameraPosition currentMapPosition;

  MapPage({LatLng currentMapPosition})
      : this.currentMapPosition = (currentMapPosition == null)
            ? null
            : CameraPosition(target: currentMapPosition, zoom: kDefaultZoom);

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  //используется для анимации состояния перехода нового пина
  AnimationController drawerAnimator;
  bool showDrawer;
  final double drawerHeight = 300;

  // насколько карта закрыта нижней панелью
  EdgeInsets mapOverlap;
  CameraPosition currentMapPosition;

  Set<Pin> pins = Set<Pin>();

  GlobalKey<CreatePinState> pinFormKey;

  FloatingActionButton fabAddPin;
  FloatingActionButton fabConfirmPin;
  FloatingActionButton currentFab;

  /// ПОПРОБОВАТЬ ИСПОЛЬЗОВАТЬ, ЧТОБЫ НЕ ЗАПРАШИВАТЬ АВТОРСТВО ИЗ БАЗЫ КАЖДЫЙ РАЗ
  // для пользователя
  FirebaseUser _user;
  Account _account;

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
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (_) => PinInfo(pin, pin.imageUrl),
    );
  }

  void barHeightChange(double height) {
    setState(() {
      mapOverlap =
          MediaQuery.of(context).padding + EdgeInsets.only(bottom: height);
    });
  }

  StreamSubscription<List<PinChange>> pinsStream;

  ///кажется что стрим работает стабильно
  void queryPins() {
    pinsStream = DatabaseMap.getPins(context).listen((pinChangesList) {
      setState(() {
        for (PinChange pinChange in pinChangesList) {
          if (pinChange.type == DocumentChangeType.added) {
            print("БЫЛ ДОБАВЛЕН МАРКЕР");
            pins.add(pinChange.pin);
            MapBodyState.markers.add(pinChange.pin.marker);
          } else if (pinChange.type == DocumentChangeType.removed) {
            print("1 ИЗ МАРКЕРОВ БЫЛ УДАЛЕН");
            MapBodyState.markers.remove(pinChange.pin.marker);
            pins.remove(pinChange.pin);
            print(pinChange.pin.name);
          } else if (pinChange.type == DocumentChangeType.modified) {
            print("1 ИЗ МАРКЕРОВ БЫЛ ИЗМЕНЕН");
            pins.removeWhere((element) =>
                element.author.toString() == pinChange.pin.author.toString() &&
                element.name.toString() == pinChange.pin.name.toString() &&
                element.imageUrl.toString() ==
                    pinChange.pin.imageUrl.toString() &&
                element.category.toString() ==
                    pinChange.pin.category.toString());
            // MapBodyState.markers.remove(pinChange.pin.marker);
            pins.add(pinChange.pin);
            MapBodyState.markers.add(pinChange.pin.marker);
            print(pinChange.pin.name);
          }
        }
      });
    });
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  ///INIT STATE
  @override
  void initState() {
    super.initState();
    drawerAnimator = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    showDrawer = false;
    mapOverlap = EdgeInsets.zero;

    currentMapPosition = (widget.currentMapPosition == null)
        ? CameraPosition(
            target: LatLng(59.933895, 30.359357), zoom: MapPage.kDefaultZoom)
        : widget.currentMapPosition;

    pinFormKey = GlobalKey<CreatePinState>();

    fabAddPin = FloatingActionButton(
      tooltip: "Add pin",
      onPressed: openDrawer,
      child: Icon(Icons.add_location),
    );

    fabConfirmPin = FloatingActionButton(
      tooltip: "Confirm",
      onPressed: () {
        if (pinFormKey.currentState.validate()) {
          pinFormKey.currentState.createPin().then((pin) {
            pins.add(pin);
            DatabaseMap.addVisited(Account.currentAccount.id, pin.id);
          });
          closeDrawer();
        }
      },
      child: Icon(Icons.check),
      backgroundColor: Colors.green,
    );

    currentFab = fabAddPin;

    SignIn.auth.currentUser().then((user) {
      Account account = Account.fromFirebaseUser(user);
      setState(() {
        _user = user;
        _account = account;
      });
    });

    queryPins();

    if (Platform.isIOS) {
      _firebaseMessaging
          .requestNotificationPermissions(IosNotificationSettings());
      _firebaseMessaging.onIosSettingsRegistered.listen((event) {
        print("IOS Registered");
      });
    }

    ///Добавил для уведомлений, нужно добавить алерт диалоги, если мы находимся
    ///в приложении (уведомления приходят только в бэкграунде)
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => UserMeetingsPage()));
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => UserMeetingsPage()));
      },
    );
  }

  ///WIDGET BUILD
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                      title: Text(
                        "Вы действительно хотите выйти?",
                        style: TextStyle(color: Colors.orange),
                      ),
                      actions: <Widget>[
                        FlatButton(
                            child: Text(
                              "Да",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.orange,
                            onPressed: () {
                              exit(0);
                            }),
                        SizedBox(
                          width: 100,
                        ),
                        FlatButton(
                          child: Text("Нет",
                              style: TextStyle(color: Colors.white)),
                          color: Colors.orange,
                          onPressed: () => Navigator.pop(context, false),
                        ),
                      ]));
          return;
        },
        child: Scaffold(
          body: MapBody(
            mapMoveCallback: (value) => currentMapPosition = value,
            initialPosition: currentMapPosition,
            mapOverlap: mapOverlap,
            drawerHeight: drawerHeight,
            pins: pins,
            pinAnimation: drawerAnimator,
            pinsStream: pinsStream,
          ),
          drawer: MenuDrawer(),
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
        ));
  }

  @override
  void dispose() {
    drawerAnimator.dispose();
    super.dispose();
  }
}

class MapBody extends StatefulWidget {
  MapBody({
    Key key,
    this.mapMoveCallback,
    this.initialPosition,
    this.mapOverlap,
    this.drawerHeight,
    this.pins,
    this.pinAnimation,
    this.pinsStream,
  }) : super(key: key);

  final Function(CameraPosition) mapMoveCallback;
  final CameraPosition initialPosition;
  final EdgeInsets mapOverlap;
  final double drawerHeight;

  Set<Pin> pins;

  final Animation<double> pinAnimation;
  final StreamSubscription<List<PinChange>> pinsStream;

  @override
  State<MapBody> createState() => MapBodyState();
}

class MapBodyState extends State<MapBody> {
  static const CameraPosition startPosition = CameraPosition(
      target: LatLng(59.933895, 30.359357), zoom: MapPage.kDefaultZoom);

  bool locationEnabled;

  // Обновляем карту и определяем пермишены. Однако, если человек установил
  // режим больше не спрашивать - не спросим
  void monitorLocationPerm() async {
    ServiceStatus currentServiceStatus, oldServiceStatus;

    while (true) {
      oldServiceStatus = currentServiceStatus;
      currentServiceStatus = await PermissionHandler()
          .checkServiceStatus(PermissionGroup.location);

      // проверяем пермишены только если изменился статус сервиса
      if (currentServiceStatus == oldServiceStatus) continue;

      // если джипиэс выключен - локация недоступна
      // кнопка *наведись на нас* пропадает
      if (currentServiceStatus == ServiceStatus.disabled) {
        setState(() {
          locationEnabled = false;
        });
        continue;
      }

      // джипиэс включили, проверяем разрешения
      PermissionStatus permissionStatus = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.location);

      if (permissionStatus == PermissionStatus.denied ||
          permissionStatus == PermissionStatus.unknown) {
        permissionStatus = (await PermissionHandler().requestPermissions(
            [PermissionGroup.location]))[PermissionGroup.location];
      }

      setState(() {
        if (permissionStatus == PermissionStatus.denied ||
            permissionStatus == PermissionStatus.neverAskAgain) {
          locationEnabled = false;
        } else if (permissionStatus == PermissionStatus.granted) {
          locationEnabled = true;
        }
      });
    }
  }

  //начальное состояние, проверяем пермишены
  @override
  void initState() {
    super.initState();
    monitorLocationPerm();
  }

  //отписываемся от стрима с пинами
  @override
  void dispose() {
    print("DISPOSE PINS STREAM");
    widget.pinsStream.cancel();
    super.dispose();
  }

  static Set<Marker> markers = Set<Marker>();

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
                  myLocationEnabled: locationEnabled,
                  myLocationButtonEnabled: locationEnabled,
                  onCameraMove: widget.mapMoveCallback,
                  gestureRecognizers: Set()
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
              child: FractionalTranslation(
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

class BottomBar extends StatelessWidget {
  final GlobalKey<CreatePinState> pinFormKey;
  final VoidCallback closeBarCallback;

  final Function(double) barHeightCallback;
  final double drawerHeight;
  final Animation<double> openAnimation;
  final bool drawerOpen;
  final Function(Pin) updateCameraPosition;

  BottomBar(
    this.pinFormKey,
    this.closeBarCallback,
    this.barHeightCallback,
    this.drawerHeight,
    this.openAnimation,
    this.drawerOpen,
    this.updateCameraPosition,
  );

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      barHeightCallback(context.size.height);
    });

    // добавляем для того, чтобы клавиатура поднимала виджет,а не закрывала его
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return BottomAppBar(
      shape: CircularNotchedRectangle(),

      //выпуклость под центральную кнопку
      notchMargin: 8.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          BottomBarNav(
            closeBarCallback,
            drawerOpen,
            updateCameraPosition,
          ),

          // по нажатию центральной кнопки - поднимаем боттем бар и
          // связанные с ним элементы, создаем новый пин
          Visibility(
            visible: drawerOpen,
            child: SizeTransition(
              sizeFactor: openAnimation,
              axisAlignment: -1.0,
              child: Padding(
                padding: EdgeInsets.only(bottom: keyboardPadding),
                //добавил 15, при изменении drawerHeight ничего не происходило
                child: CreatePin(drawerHeight + 15, key: pinFormKey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomBarNav extends StatelessWidget {
  final VoidCallback closeBarCallback;
  final bool drawerOpen;
  final Function(Pin) updateMapPosition;

  BottomBarNav(
    this.closeBarCallback,
    this.drawerOpen,
    this.updateMapPosition,
  );

  @override
  Widget build(BuildContext context) {
    Set<Pin> pins = context.findAncestorStateOfType<MapPageState>().pins;

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Visibility(
          visible: !drawerOpen,
          child: IconButton(
            iconSize: 40,
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: Icon(
              Icons.menu,
              semanticLabel: "Menu",
            ),
          ),

          //когда нажимаем центральную кнопку, иконка меню заменяется
          //на стрелочку назад
          replacement: IconButton(
            iconSize: 40,
            onPressed: () {
              closeBarCallback();
            },
            icon: Icon(
              Icons.arrow_back,
              semanticLabel: "Cancel",
            ),
          ),
        ),

        Visibility(
            visible: !drawerOpen,
            child: IconButton(
              iconSize: 40,
              onPressed: () async {
                Pin pin = await showSearch(
                    context: context, delegate: MapSearchDelegate(pins));
                updateMapPosition(pin);
              },
              icon: Icon(
                Icons.search,
                color: Colors.orange,
                semanticLabel: "Search",
              ),
            )),

        //раскидываем кнопки по разным концам
        Spacer(),
        Visibility(
            visible: !drawerOpen,
            child: IconButton(
              iconSize: 40,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserMeetingsPage()));
              },
              icon: Icon(
                Icons.emoji_people,
                color: Colors.orange,
                semanticLabel: "Meetings",
              ),
            )),

        PopupMenuButton(
          tooltip: "Help",
          icon: Icon(
            Icons.help,
            color: Colors.black,
          ),
          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
            const PopupMenuItem(
              child: Text(
                  "\nЭто наша карта. Здесь можно свободно перемещаться и узнавать информацию о местах кликнув по ним.\n"
                  "\nВы можете добавить свой собственный пин, нажав кнопку с плюсом и центрируя экран в нужном месте.\n"
                  "\nВы также можете найти пин по названию с помощью значка поиска.\n",
                  textAlign: TextAlign.justify),
            ),
          ],
        ),
      ],
    );
  }
}
