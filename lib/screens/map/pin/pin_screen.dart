import 'package:coworking/navigation/main_navigation.dart';
import 'package:coworking/screens/map/pin/pin_screen_model.dart';
import 'package:coworking/services/database_review.dart';
import 'package:coworking/widgets/google_map_button.dart';
import 'package:flutter/material.dart';
import 'package:coworking/models/category.dart';
import 'package:coworking/services/database_pin.dart';
import 'package:coworking/models/pin.dart';
import 'package:coworking/models/review.dart';
import 'package:coworking/screens/map/pin/review/reviews_list.dart';
import 'package:coworking/screens/map/pin/review/review_form.dart';
import 'package:coworking/widgets/image_picker_box.dart';
import 'package:coworking/widgets/radio_button_picker.dart';
import 'package:provider/provider.dart';

class PinScreen extends StatelessWidget {
  final Pin pin;
  const PinScreen({Key? key, required this.pin}) : super(key: key);

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => PinModel(pin),
        lazy: true,
        child: const _PinView(),
      );
}

class _PinView extends StatelessWidget {
  const _PinView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PinModel>();
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        tooltip: "Write review",
        child: const Icon(Icons.create),
        onPressed: () => showModalBottomSheet(
          context: context,
          builder: (_) => Scaffold(
            appBar: AppBar(
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () async {
                    if (model.reviewFormKey.currentState!.isValid) {
                      Review review =
                          model.reviewFormKey.currentState!.getReview();
                      model.pin.addReview(review);
                      model.pin.rating =
                          await DatabasePin.updateRateOfPin(model.pin.id);
                      Navigator.pop(context);
                    }
                  },
                )
              ],
            ),
            body: ReviewForm(key: model.reviewFormKey),
          ),
        ),
      ),
      body: StreamBuilder<List<Review>>(
        stream: DatabaseReview.fetchReviewsForPin(model.pin.id),
        builder: (context, snapshot) {
          Widget progressIndicator = Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(24),
            child: const CircularProgressIndicator(),
          );
          return CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: <Widget>[
              const _PinAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        model.pin.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 22, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text("Категория:"),
                      ),
                      const _CategoryChipWidget(),
                      FutureBuilder(
                          future: DatabasePin.updateRateOfPin(model.pin.id),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              model.pin.rating = snapshot.data as double;
                              return (snapshot.hasData)
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Text(
                                        "Рейтинг: " +
                                            model.pin.rating.toString() +
                                            " / 10",
                                      ),
                                    )
                                  : Container();
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          })
                    ]),
                    GoogleMapButton(location: model.pin.location),
                    Container(
                      alignment: Alignment.center,
                      child: const Text(
                        "Статистика за последние 3 месяца",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const _ThreeMonthRateWidget(),
                    Container(
                      alignment: Alignment.center,
                      child: const Text(
                        "Отзывы",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              snapshot.hasData
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => PinListItem(snapshot.data![i]),
                        childCount: snapshot.data!.length,
                      ),
                    )
                  : SliverFillRemaining(
                      child: progressIndicator,
                      hasScrollBody: false,
                    ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 100,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PinAppBar extends StatelessWidget {
  const _PinAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PinModel>();
    return SliverAppBar(
      pinned: true,
      floating: false,
      backgroundColor: Colors.orange,
      expandedHeight: 350,
      actions: const <Widget>[
        _FavouriteButton(),
        _EditPinButton(),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          model.pin.imageUrl,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

class _FavouriteButton extends StatelessWidget {
  const _FavouriteButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PinModel>();
    return FutureBuilder(
      future: DatabasePin.isFavourite(model.pin.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else if (snapshot.data == true) {
          model.visitedText = "В избранном";
          model.visitedColor = Colors.yellow;
        } else {
          model.visitedText = "Добавить в избранное";
          model.visitedColor = Colors.grey;
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            child: Text(model.visitedText),
            onPressed: () {
              if (snapshot.data == false) {
                model.setFavourite();
              } else {
                model.setUnFavourite();
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(model.visitedColor),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EditPinButton extends StatelessWidget {
  const _EditPinButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PinModel>();

    _editPinForm() {
      return Scaffold(
        appBar: AppBar(actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              var errorSave = await model.savePin();
              if (errorSave) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Вы заполнили не всю информацию"),
                ));
              } else {
                Navigator.of(context).pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Информация о месте изменена"),
                ));
              }
            },
          )
        ]),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Form(
              key: model.formKey,
              child: Column(
                children: <Widget>[
                  ImagePickerBox(
                    key: model.imagePickerKey,
                    validator: (image) =>
                        image == null ? "Необходима фотография места" : null,
                  ),
                  RadioButtonPicker(
                    key: model.categoryPickerKey,
                    validator: (option) =>
                        option == null ? "Необходима категория места" : null,
                    options: Category.all(),
                  ),
                  const SizedBox(height: 10,),
                  TextFormField(
                    controller: model.nameController,
                    validator: (text) =>
                        text!.isEmpty ? "Необходимо название места" : null,
                    decoration: const InputDecoration(
                      hintText: "Название места",
                      contentPadding: EdgeInsets.all(8.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(
                            MainNavigationRouteNames.mapScreen,
                            arguments: model.pin.location);
        
                        DatabasePin.deletePin(model.pin);
                      },
                      child: const Text(
                        'Удалить',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26.0,
                        ),
                      ),
                      style: ButtonStyle(
                          padding:
                              MaterialStateProperty.all(const EdgeInsets.all(10)),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.red)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return FutureBuilder(
      future: DatabasePin.isPinOwner(model.pin),
      builder: (context, snapshot) {
        // model.setKeys();
        if (snapshot.hasData) {
          return (snapshot.data == true)
              ? WillPopScope(
                  onWillPop: () async {
                    return true;
                  },
                  child: IconButton(
                    icon: const Icon(
                      Icons.edit_location_rounded,
                      color: Colors.white,
                      semanticLabel: "Edit Pin",
                      size: 35,
                    ),
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      builder: (_) => _editPinForm(),
                    ),
                  ),
                )
              : Container();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class _ThreeMonthRateWidget extends StatelessWidget {
  const _ThreeMonthRateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PinModel>();
    return FutureBuilder(
      future: DatabasePin.calculateThreeMonthRate(model.pin.id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          model.threeMonthStats = snapshot.data as List<double>;
          return (snapshot.hasData)
              ? GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 6,
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      child: const Text("Можно приобрести еду"),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                          model.threeMonthStats.elementAt(1).toString() +
                              "% ответили да"),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: const Text("Можно находиться бесплатно"),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                          model.threeMonthStats.elementAt(2).toString() +
                              "% ответили да"),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: const Text("Есть розетки"),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                          model.threeMonthStats.elementAt(3).toString() +
                              "% ответили да"),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: const Text("Есть WiFi"),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                          model.threeMonthStats.elementAt(4).toString() +
                              "% ответили да"),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: const Text("Оценка"),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                          model.threeMonthStats.elementAt(0).toString() +
                              "/10"),
                    ),
                  ],
                )
              : Container();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class _CategoryChipWidget extends StatelessWidget {
  const _CategoryChipWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PinModel>();
    return Chip(
      label: Text(model.pin.category.text),
      labelStyle: const TextStyle(color: Colors.white),
      backgroundColor: model.pin.category.colour,
    );
  }
}
