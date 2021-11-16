import 'package:coworking/navigation/main_navigation.dart';
import 'package:coworking/services/database_review.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coworking/models/account.dart';
import 'package:coworking/models/category.dart';
import 'package:coworking/services/database_pin.dart';
import 'package:coworking/models/pin.dart';
import 'package:coworking/models/review.dart';
import 'package:coworking/screens/menu/review_tile.dart';
import 'package:coworking/screens/map/pin/review/review_form.dart';
import 'package:coworking/widgets/image_picker_box.dart';
import 'package:coworking/widgets/radio_button_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PinScreen extends StatefulWidget {
  final Pin pin;

  const PinScreen(this.pin, {Key? key}) : super(key: key);

  @override
  _PinScreenState createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  late GlobalKey<ReviewFormState> reviewFormKey;
  var visitedText = "";
  var visitedColor = Colors.orange;
  var threeMonthSet = [];

  @override
  void initState() {
    reviewFormKey = GlobalKey<ReviewFormState>();
    super.initState();
    threeMonthSet = [0, 0, 0, 0, 0];
  }

  @override
  Widget build(BuildContext context) {
    // достаем информацию посещали ли место
    Widget favouriteButton = FutureBuilder(
      future: DatabasePin.isFavourite(widget.pin.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else if (snapshot.data == true) {
          visitedText = "В избранном";
          visitedColor = Colors.yellow;
        } else {
          visitedText = "Добавить в избранное";
          visitedColor = Colors.grey;
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            child: Text(visitedText),
            onPressed: () {
              if (snapshot.data == false) {
                setState(() {
                  visitedText = "Добавить в избранное";
                  visitedColor = Colors.grey;
                });
                DatabasePin.addFavourite(widget.pin.id);
              } else {
                setState(() {
                  visitedText = "В избранном";
                  visitedColor = Colors.yellow;
                });
                DatabasePin.removeFavourite(widget.pin.id);
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(visitedColor),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: visitedColor),
                ),
              ),
            ),
          ),
        );
      },
    );

    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    GlobalKey<FormFieldState> imagePickerKey = GlobalKey<FormFieldState>();
    GlobalKey<FormFieldState> categoryPickerKey = GlobalKey<FormFieldState>();
    TextEditingController nameController = TextEditingController();

    void _savePin() async {
      var newImage = imagePickerKey.currentState!.value;
      var timeKey = DateTime.now();
      final Reference postImageRef =
          FirebaseStorage.instance.ref().child("Pin Images");
      final UploadTask uploadTask =
          postImageRef.child(timeKey.toString() + ".jpg").putFile(newImage);

      String stringUrl = await (await uploadTask).ref.getDownloadURL();
      Category category = categoryPickerKey.currentState!.value;

      widget.pin.imageUrl = stringUrl;
      widget.pin.name = nameController.text;
      widget.pin.category.text = category.text;
      if (_formKey.currentState!.validate()) {
        if (widget.pin.name != "" &&
            widget.pin.category.text != "" &&
            widget.pin.imageUrl.isNotEmpty) {
          await DatabasePin().editPin(widget.pin);
          setState(() {
            widget.pin.imageUrl = stringUrl;
            widget.pin.name = nameController.text;
            widget.pin.category.text = category.text;
          });
          Navigator.of(context).pop(context);
          Clipboard.setData(ClipboardData(text: widget.pin.name));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(widget.pin.name),
          ));
        }
      }
    }

    editPinButton(context) => FutureBuilder(
        future: DatabasePin.isPinOwner(widget.pin),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return (snapshot.data == true)
                ? WillPopScope(
                    onWillPop: () async {
                      return true;
                    },
                    child: IconButton(
                        icon: const Icon(
                          Icons.edit_location_rounded,
                          color: Colors.orange,
                          semanticLabel: "Edit Pin",
                          size: 35,
                        ),
                        color: Colors.white,
                        onPressed: () => showModalBottomSheet(
                              context: context,
                              builder: (_) => Scaffold(
                                  appBar: AppBar(actions: <Widget>[
                                    IconButton(
                                      icon: const Icon(Icons.save),
                                      onPressed: () {
                                        _savePin();
                                      },
                                    )
                                  ]),
                                  body: SingleChildScrollView(
                                    child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Form(
                                          key: _formKey,
                                          child: Column(children: <Widget>[
                                            ImagePickerBox(
                                              key: imagePickerKey,
                                              validator: (image) => image ==
                                                      null
                                                  ? "Необходима фотография места"
                                                  : null,
                                            ),
                                            RadioButtonPicker(
                                              key: categoryPickerKey,
                                              validator: (option) => option ==
                                                      null
                                                  ? "Необходима категория места"
                                                  : null,
                                              options: Category.all(),
                                            ),
                                            TextFormField(
                                              controller: nameController,
                                              validator: (text) => text!.isEmpty
                                                  ? "Необходимо название места"
                                                  : null,
                                              decoration: const InputDecoration(
                                                hintText: "Название места",
                                                contentPadding:
                                                    EdgeInsets.all(8.0),
                                              ),
                                            ),
                                            ButtonTheme(
                                              minWidth: 120.0,
                                              height: 60.0,
                                              child: ElevatedButton(
                                                // удаление
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pushReplacementNamed(
                                                          MainNavigationRouteNames
                                                              .mapScreen,
                                                          arguments: widget
                                                              .pin.location);
                                                  setState(() {
                                                    DatabasePin.deletePin(
                                                        widget.pin);
                                                  });
                                                },
                                                child: const Text(
                                                  'Удалить',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 26.0,
                                                  ),
                                                ),
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.red)),
                                              ),
                                            ),
                                          ]),
                                        )),
                                  )),
                            )))
                : Container();
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });

    Widget bar = SliverAppBar(
      pinned: true,
      floating: true,
      stretch: true,
      onStretchTrigger: () async {
        Navigator.maybePop(context);
      },
      backgroundColor: Colors.grey,
      expandedHeight: 400,
      actions: <Widget>[
        favouriteButton,
        editPinButton(context),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Container(
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(2.0)),
            ),
            child: Text(
              widget.pin.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black, fontSize: 22),
              textAlign: TextAlign.center,
            )),
        background: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.network(
              widget.pin.imageUrl,
              fit: BoxFit.fill,
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        tooltip: "Write review",
        child: const Icon(Icons.create),
        onPressed: () => showModalBottomSheet(
          context: context,
          builder: (_) => Scaffold(
            appBar: AppBar(actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () async {
                  if (reviewFormKey.currentState!.isValid) {
                    Review review = reviewFormKey.currentState!.getReview();
                    widget.pin.addReview(review);
                    widget.pin.rating =
                        await DatabasePin.updateRateOfPin(widget.pin.id);
                    Navigator.pop(context);
                  }
                },
              )
            ]),
            body: ReviewForm(key: reviewFormKey),
          ),
        ),
      ),
      body: StreamBuilder<List<Review>>(
          stream: DatabaseReview.getReviewsForPin(widget.pin.id),
          builder: (context, snapshot) {
            Widget progressIndicator = Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(24),
              child: const CircularProgressIndicator(),
            );

            Category category = widget.pin.category;
            Widget categoryChip = Chip(
              label: Text(category.text),
              labelStyle: const TextStyle(color: Colors.white),
              backgroundColor: category.colour,
            );

            return CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: <Widget>[
                bar,
                SliverToBoxAdapter(
                    child: Column(
                  children: <Widget>[
                    Row(children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text("Категория:"),
                      ),
                      categoryChip,
                      FutureBuilder(
                          future: DatabasePin.updateRateOfPin(widget.pin.id),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              widget.pin.rating = snapshot.data as double;
                              return (snapshot.hasData)
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Text(
                                        "Рейтинг: " +
                                            widget.pin.rating.toString() +
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
                    Container(
                      alignment: Alignment.center,
                      child: const Text(
                        "Статистика за последние 3 месяца",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    FutureBuilder(
                        future: DatabasePin.threeMonthRate(widget.pin.id),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            threeMonthSet = snapshot.data as List;
                            return (snapshot.hasData)
                                ? GridView.count(
                                    childAspectRatio: 6,
                                    crossAxisCount: 2,
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16),
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child:
                                            const Text("Можно приобрести еду"),
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: Text(threeMonthSet
                                                .elementAt(1)
                                                .toString() +
                                            "% ответили да"),
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: const Text(
                                            "Можно находиться бесплатно"),
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: Text(threeMonthSet
                                                .elementAt(2)
                                                .toString() +
                                            "% ответили да"),
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: const Text("Есть розетки"),
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: Text(threeMonthSet
                                                .elementAt(3)
                                                .toString() +
                                            "% ответили да"),
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: const Text("Есть WiFi"),
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: Text(threeMonthSet
                                                .elementAt(4)
                                                .toString() +
                                            "% ответили да"),
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: const Text("Оценка"),
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: Text(threeMonthSet
                                                .elementAt(0)
                                                .toString() +
                                            "/10"),
                                      ),
                                    ],
                                  )
                                : Container();
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        }),
                    Container(
                      alignment: Alignment.center,
                      child: const Text(
                        "Отзывы",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )),

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

                ///возможно потом верну
                const SliverFillRemaining(
                  hasScrollBody: true,
                ),
                // SliverToBoxAdapter(
                //   child: Padding(padding: EdgeInsets.all(1.0)),
                // )
              ],
            );
          }),
    );
  }
}
