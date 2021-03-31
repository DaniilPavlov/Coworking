import 'package:coworking/resources/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coworking/resources/account.dart';
import 'package:coworking/resources/category.dart';
import 'package:coworking/resources/database.dart';
import 'package:coworking/resources/pin.dart';
import 'package:coworking/resources/review.dart';
import 'package:coworking/screens/comment_tile.dart';
import 'package:coworking/screens/new_review_form.dart';
import 'package:coworking/widgets/image_picker_box.dart';
import 'package:coworking/widgets/radio_button_picker.dart';
import 'map.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:coworking/widgets/check_box_picker.dart';

class PinInfo extends StatefulWidget {
  final Pin pin;
  String imgURL;

  PinInfo(this.pin, this.imgURL);

  @override
  _PinInfoState createState() => _PinInfoState();
}

class _PinInfoState extends State<PinInfo> {
  GlobalKey<NewReviewFormState> reviewFormKey;

  @override
  void initState() {
    reviewFormKey = GlobalKey<NewReviewFormState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // достаем информацию посещали ли место
    Widget visitedButton = StreamBuilder<List<String>>(
      stream: Database.visitedByUser(Account.currentAccount, context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        return Padding(
          padding: EdgeInsets.all(8.0),
          child: RaisedButton(
            child: Text("Посещено"),
            onPressed: () {
              if (snapshot.data.contains(widget.pin.id)) {
                Database.deleteVisited(
                    Account.currentAccount.id, widget.pin.id);
              } else {
                Database.addVisited(Account.currentAccount.id, widget.pin.id);
              }
            },
            shape: StadiumBorder(),
            color: snapshot.data.contains(widget.pin.id)
                ? Colors.green
                : Colors.red,
            textColor: Theme.of(context).primaryTextTheme.button.color,
          ),
        );
      },
    );

    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    GlobalKey<FormFieldState> imagePickerKey = GlobalKey<FormFieldState>();
    GlobalKey<FormFieldState> categoryPickerKey = GlobalKey<FormFieldState>();
    TextEditingController nameController = TextEditingController();

    void _savePin() async {

      var newImage = imagePickerKey.currentState.value;
      var timeKey = new DateTime.now();
      final StorageReference postImageRef =
          FirebaseStorage.instance.ref().child("Pin Images");
      final StorageUploadTask uploadTask =
          postImageRef.child(timeKey.toString() + ".jpg").putFile(newImage);

      String stringUrl =
          await (await uploadTask.onComplete).ref.getDownloadURL();
      Category category = categoryPickerKey.currentState.value;

      widget.pin.imageUrl = stringUrl;
      widget.pin.name = nameController.text;
      widget.pin.category.text = category.text;
      if (_formKey.currentState.validate()) {
        if (widget.pin.name != "" &&
            widget.pin.category.text != "" &&
            widget.pin.imageUrl.isNotEmpty) {
          await Database().editPin(widget.pin);
          setState(() {
            widget.imgURL = stringUrl;
            widget.pin.name = nameController.text;
            widget.pin.category.text = category.text;
          });
          Navigator.of(context).pop(context);
          Clipboard.setData(ClipboardData(text: widget.pin.name));
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(widget.pin.name),
          ));
        }
      }
    }

    ///нужно переделать кнопку в изменить пин для создателя \ админа
    ///
    ///
    Widget editPinButton(context) => Builder(
        builder: (context) => IconButton(
            icon: Icon(
              Icons.edit_location_rounded,
              color: Colors.orange,
              semanticLabel: "Edit Pin",
              size: 35,
            ),
            color: Colors.white,
            onPressed: () => showModalBottomSheet(
                context: context,
                builder: (_) => FutureBuilder(
                    future: Database.isPinOwner(widget.pin),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return (snapshot.data == true)
                            ? WillPopScope(
                                onWillPop: () async {
                                  return true;
                                },
                                child: Scaffold(
                                    appBar: AppBar(actions: <Widget>[
                                      IconButton(
                                        icon: Icon(Icons.save),
                                        onPressed: () {
                                          _savePin();
                                        },
                                      )
                                    ]),
                                    body: SingleChildScrollView(
                                      child: Container(
                                          padding: EdgeInsets.all(10),
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
                                                validator: (text) => text
                                                        .isEmpty
                                                    ? "Необходимо название места"
                                                    : null,
                                                decoration: InputDecoration(
                                                  hintText: "Название места",
                                                  contentPadding:
                                                      EdgeInsets.all(8.0),
                                                ),
                                              ),
                                              ButtonTheme(
                                                minWidth: 120.0,
                                                height: 60.0,
                                                child: RaisedButton(
                                                  onPressed: () {
                                                    // удаление
                                                    setState(() {
                                                      MapBodyState
                                                          .doPinToDelete(
                                                              widget.pin);
                                                      Database.deletePin(
                                                          widget.pin);
                                                    });
                                                    Navigator.of(context)
                                                        .pop(context);
                                                    // Clipboard.setData(ClipboardData(text: widget.pin.name));
                                                    // Scaffold.of(context).showSnackBar(SnackBar(
                                                    //   content: Text(widget.pin.name),
                                                    // ));
                                                  },
                                                  child: Text(
                                                    'Удалить',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 26.0,
                                                    ),
                                                  ),
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ]),
                                          )),
                                    )),
                              )
                            : Container();
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    })))
        // Clipboard.setData(
        //     ClipboardData(text: widget.pin.id.hashCode.toString()));
        // Scaffold.of(context).showSnackBar(SnackBar(
        //   content: Text("Пин изменен"),
        // ));

        );

    Widget bar = SliverAppBar(
      pinned: true,
      floating: true,
      stretch: true,
      onStretchTrigger: () async {
        Navigator.maybePop(context);
      },
      backgroundColor: Colors.grey,
      expandedHeight: 450,
      actions: <Widget>[
        visitedButton,
        editPinButton(context),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Container(
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Text(
              widget.pin.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black, fontSize: 22),
              textAlign: TextAlign.center,
            )),
        background: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.network(
              widget.imgURL,
              fit: BoxFit.scaleDown,
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        tooltip: "Write review",
        child: Icon(Icons.create),
        onPressed: () => showModalBottomSheet(
          context: context,
          builder: (_) => Scaffold(
            appBar: AppBar(actions: <Widget>[
              IconButton(
                icon: Icon(Icons.save),
                onPressed: () {
                  if (reviewFormKey.currentState.isValid) {
                    Review review = reviewFormKey.currentState.getReview();
                    widget.pin.addReview(review);
                    Navigator.pop(context);
                  }
                },
              )
            ]),
            body: NewReviewForm(key: reviewFormKey),
          ),
        ),
      ),
      body: StreamBuilder(
          stream: Database.getReviewsForPin(widget.pin.id),
          builder: (context, snapshot) {
            Widget progressIndicator = Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            );

            Category category = widget.pin.category;
            Widget categoryChip = Chip(
              label: Text(category.text),
              labelStyle: TextStyle(color: Colors.white),
              backgroundColor: category.colour,
            );

            return CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: <Widget>[
                bar,
                SliverToBoxAdapter(
                  child: Column(children: <Widget>[
                    Row(children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text("Категория:"),
                      ),
                      categoryChip,
                    ]),
                    Wrap(
                      spacing: 8.0,
                      children: List.generate(widget.pin.tags.length, (i) {
                        Tag tag = widget.pin.tags.elementAt(i);
                        return Chip(
                          label: Text(tag.text),
                          labelStyle: TextStyle(color: Colors.white),
                          backgroundColor: tag.colour,
                        );
                      }),
                    ),
                  ]),
                ),
                snapshot.hasData
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => PinListItem(snapshot.data[i]),
                          childCount: snapshot.data.length,
                        ),
                      )
                    : SliverFillRemaining(
                        child: progressIndicator,
                        hasScrollBody: false,
                      ),
                SliverFillRemaining(hasScrollBody: false),
                SliverToBoxAdapter(
                  child: Padding(padding: EdgeInsets.all(1.0)),
                )
              ],
            );
          }),
    );
  }
}
