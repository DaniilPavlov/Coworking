import 'dart:io';

import 'package:coworking/domain/entities/category.dart';
import 'package:coworking/domain/entities/pin.dart';
import 'package:coworking/domain/entities/review.dart';
import 'package:coworking/domain/services/database_pin.dart';
import 'package:coworking/domain/services/database_review.dart';
import 'package:coworking/navigation/main_navigation.dart';
import 'package:coworking/screens/map/pin/pin_screen_model.dart';
import 'package:coworking/screens/map/pin/review/review_form.dart';
import 'package:coworking/screens/map/pin/review/review_widget.dart';
import 'package:coworking/widgets/custom_progress_indicator.dart';
import 'package:coworking/widgets/google_map_button.dart';
import 'package:coworking/widgets/radio_button_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PinScreen extends StatelessWidget {
  const PinScreen({required this.pin, super.key});
  final Pin pin;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => PinScreenModel(pin: pin),
        lazy: true,
        child: const _PinScreenView(),
      );
}

class _PinScreenView extends StatelessWidget {
  const _PinScreenView();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PinScreenModel>();

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: const _FloatingReviewButton(),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: <Widget>[
          const _PinAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                const _PinNameWidget(),
                Row(
                  children: const [
                    _CategoryChipWidget(),
                    _WholeTimeRateWidget(),
                  ],
                ),
                GoogleMapButton(location: model.pin.location),
                const _ThreeMonthRateWidget(),
                Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Отзывы',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const _ReviewsList(),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewsList extends StatelessWidget {
  const _ReviewsList();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PinScreenModel>();
    return StreamBuilder<List<Review>>(
      stream: DatabaseReview.fetchReviewsForPin(model.pin),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => ReviewWidget(key: ValueKey(snapshot.data![i].id), review: snapshot.data![i]),
                  childCount: snapshot.data!.length,
                ),
              )
            : const SliverFillRemaining(
                hasScrollBody: false,
                child: CustomProgressIndicator(),
              );
      },
    );
  }
}

class _PinNameWidget extends StatelessWidget {
  const _PinNameWidget();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PinScreenModel>();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        model.pin.name,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 22, fontStyle: FontStyle.italic),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _WholeTimeRateWidget extends StatelessWidget {
  const _WholeTimeRateWidget();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PinScreenModel>();
    return StreamBuilder(
      stream: DatabasePin.fetchPin(model.pin.id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          model.pin.rating = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.only(left: 8, right: 16),
            child: Text(
              'Рейтинг: ${model.pin.rating} / 10',
            ),
          );
        } else {
          return const CustomProgressIndicator();
        }
      },
    );
  }
}

class _FloatingReviewButton extends StatelessWidget {
  const _FloatingReviewButton();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PinScreenModel>();
    return FloatingActionButton(
      backgroundColor: Colors.orange,
      tooltip: 'Write review',
      child: const Icon(Icons.create),
      onPressed: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.orange,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () async {
                  await model.createReview(context);
                },
              ),
            ],
          ),
          body: ReviewForm(key: model.reviewFormKey),
        ),
      ),
    );
  }
}

class _PinAppBar extends StatelessWidget {
  const _PinAppBar();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PinScreenModel>();
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.orange,
      expandedHeight: 350,
      actions: <Widget>[
        const DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.all(
              Radius.circular(18),
            ),
          ),
          child: Row(
            children: [
              _FavouriteButton(),
              _EditPinButton(),
            ],
          ),
        ),
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
  const _FavouriteButton();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PinScreenModel>();
    return FutureBuilder(
      future: DatabasePin.isFavourite(model.pin.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else if (snapshot.data ?? false) {
          model
            ..visitedText = 'В избранном'
            ..visitedColor = Colors.yellow;
        } else {
          model
            ..visitedText = 'Добавить в избранное'
            ..visitedColor = Colors.grey;
        }
        return Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton(
            onPressed: () {
              if (snapshot.data == false) {
                model.setFavourite();
              } else {
                model.setUnfavourite();
              }
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(model.visitedColor),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            child: Text(model.visitedText),
          ),
        );
      },
    );
  }
}

class _EditPinButton extends StatelessWidget {
  const _EditPinButton();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PinScreenModel>();

    Widget saveButton() {
      return IconButton(
        icon: const Icon(Icons.save),
        onPressed: () async {
          final errorSave = await model.savePin();
          if (errorSave && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Вы заполнили не всю информацию'),
              ),
            );
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Информация о месте изменена'),
              ),
            );
            Navigator.of(context).pop(context);
          }
        },
      );
    }

    Scaffold editPinForm() {
      return Scaffold(
        appBar: AppBar(actions: <Widget>[saveButton()]),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Form(
              key: model.formKey,
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () async {
                      await model.setNewPhoto();
                    },
                    // TODO(check): can't switch widgets after uploading photo
                    child: model.newPhotoPath == ''
                        ? Image.network(
                            model.pin.imageUrl,
                            height: MediaQuery.of(context).size.width,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fill,
                          )
                        : Image.file(
                            File(model.newPhotoPath),
                            height: MediaQuery.of(context).size.width,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fill,
                          ),
                  ),
                  RadioButtonPicker(
                    key: model.categoryPickerKey,
                    validator: (option) => option == null ? 'Необходима категория места' : null,
                    options: Category.all(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: model.nameController,
                    validator: (text) => text!.isEmpty ? 'Необходимо название места' : null,
                    decoration: const InputDecoration(
                      hintText: 'Название места',
                      contentPadding: EdgeInsets.all(8),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(
                          MainNavigationRouteNames.mapScreen,
                          arguments: model.pin.location,
                        );

                        DatabasePin.deletePin(model.pin);
                      },
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.all(10),
                        ),
                        backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
                      ),
                      child: const Text(
                        'Удалить',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
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
        if (snapshot.hasData) {
          return (snapshot.data ?? false)
              ? WillPopScope(
                  onWillPop: () async {
                    return true;
                  },
                  child: IconButton(
                    icon: const Icon(
                      Icons.edit_location_rounded,
                      color: Colors.black,
                      semanticLabel: 'Edit Pin',
                      size: 35,
                    ),
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => editPinForm(),
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

class _CategoryChipWidget extends StatelessWidget {
  const _CategoryChipWidget();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PinScreenModel>();
    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, right: 8),
          child: Text('Категория:'),
        ),
        Chip(
          label: Text(model.pin.category.text),
          labelStyle: const TextStyle(color: Colors.white),
          backgroundColor: model.pin.category.colour,
        ),
      ],
    );
  }
}

class _ThreeMonthRateWidget extends StatelessWidget {
  const _ThreeMonthRateWidget();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PinScreenModel>();
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: const Text(
            'Статистика за последние 3 месяца',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        StreamBuilder(
          stream: DatabasePin.calculateThreeMonthRate(model.pin.id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              debugPrint('banan ${snapshot.data}');
              model.threeMonthStats = snapshot.data!;
              return (snapshot.hasData)
                  ? GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 4,
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          child: const Text('Можно приобрести еду'),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            model.threeMonthStats.elementAt(1).isNaN
                                ? 'Нет данных'
                                : '${model.threeMonthStats.elementAt(1)}% ответили да',
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: const Text('Можно находиться бесплатно'),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            model.threeMonthStats.elementAt(2).isNaN
                                ? 'Нет данных'
                                : '${model.threeMonthStats.elementAt(2)}% ответили да',
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: const Text('Есть розетки'),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            model.threeMonthStats.elementAt(3).isNaN
                                ? 'Нет данных'
                                : '${model.threeMonthStats.elementAt(3)}% ответили да',
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: const Text('Есть WiFi'),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            model.threeMonthStats.elementAt(4).isNaN
                                ? 'Нет данных'
                                : '${model.threeMonthStats.elementAt(4)}% ответили да',
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: const Text('Оценка'),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            model.threeMonthStats.elementAt(0).isNaN
                                ? 'Нет данных'
                                : '${model.threeMonthStats.elementAt(0)}/10',
                          ),
                        ),
                      ],
                    )
                  : Container();
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ],
    );
  }
}
