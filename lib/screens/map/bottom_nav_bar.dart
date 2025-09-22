import 'package:coworking/domain/entities/pin.dart';
import 'package:coworking/navigation/main_navigation.dart';
import 'package:coworking/screens/map/map_screen.dart';
import 'package:coworking/screens/map/map_search.dart';
import 'package:coworking/screens/map/pin/create_pin.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  const BottomBar(
    this.pinFormKey,
    this.closeBarCallback,
    this.barHeightCallback,
    this.drawerHeight,
    this.openAnimation,
    this.drawerOpen,
    this.openPinFromSearch, {
    super.key,
  });
  final GlobalKey<CreatePinState> pinFormKey;
  final VoidCallback closeBarCallback;

  final Function(double) barHeightCallback;
  final double drawerHeight;
  final Animation<double> openAnimation;
  final bool drawerOpen;
  final Function(Pin) openPinFromSearch;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      barHeightCallback(context.size!.height);
    });

    // добавляем для того, чтобы клавиатура поднимала виджет,а не закрывала его
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Visibility(
                visible: !drawerOpen,
                replacement: IconButton(
                  iconSize: 40,
                  onPressed: closeBarCallback,
                  icon: const Icon(
                    Icons.arrow_back,
                    semanticLabel: 'Cancel',
                  ),
                ),
                child: IconButton(
                  iconSize: 40,
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: const Icon(
                    Icons.menu,
                    semanticLabel: 'Menu',
                  ),
                ),
              ),
              SearchButton(
                drawerOpen: drawerOpen,
                updateCameraPosition: openPinFromSearch,
              ),
              const Spacer(),
              MeetingsButton(drawerOpen: drawerOpen),
              const HintButton(),
            ],
          ),
          // по нажатию центральной кнопки - поднимаем боттем бар и
          // связанные с ним элементы, создаем новый пин
          Visibility(
            visible: drawerOpen,
            child: SizeTransition(
              sizeFactor: openAnimation,
              axisAlignment: -1,
              child: Padding(
                padding: EdgeInsets.only(bottom: keyboardPadding),
                //добавил 15, при изменении drawerHeight ничего не происходило
                child: CreatePin(drawerHeight, key: pinFormKey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchButton extends StatelessWidget {
  const SearchButton({
    required this.drawerOpen,
    required this.updateCameraPosition,
    super.key,
  });
  final bool drawerOpen;
  final Function(Pin) updateCameraPosition;

  @override
  Widget build(BuildContext context) {
    final Set<Pin> pins = context.findAncestorStateOfType<MapScreenState>()!.pins;
    return Visibility(
      visible: !drawerOpen,
      child: IconButton(
        iconSize: 40,
        onPressed: () async {
          final Pin? pin = await showSearch(
            context: context,
            delegate: MapSearchDelegate(pins),
          );
          if (pin != null) {
            updateCameraPosition(pin);
          }
        },
        icon: const Icon(
          Icons.search,
          color: Colors.orange,
          semanticLabel: 'Search',
        ),
      ),
    );
  }
}

class MeetingsButton extends StatelessWidget {
  const MeetingsButton({required this.drawerOpen, super.key});
  final bool drawerOpen;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !drawerOpen,
      child: IconButton(
        iconSize: 40,
        onPressed: () {
          Navigator.of(context).pushNamed(MainNavigationRouteNames.meetingsScreen);
        },
        icon: const Icon(
          Icons.emoji_people,
          color: Colors.orange,
          semanticLabel: 'Meetings',
        ),
      ),
    );
  }
}

class HintButton extends StatelessWidget {
  const HintButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      tooltip: 'Help',
      icon: const Icon(
        Icons.help,
        color: Colors.black,
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        const PopupMenuItem(
          child: Text(
            '\nЭто наша карта. Здесь можно свободно перемещаться и узнавать информацию о местах кликнув по ним.\n'
            '\nВы можете добавить свой собственный пин, нажав кнопку с плюсом и центрируя экран в нужном месте.\n'
            '\nВы также можете найти пин по названию с помощью значка поиска.\n',
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}
