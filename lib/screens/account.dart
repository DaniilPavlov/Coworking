import 'package:coworking/resources/account.dart';
import 'package:coworking/resources/database.dart';
import 'package:coworking/resources/review.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:coworking/screens/login.dart';

import '../main.dart';
import '../sign_in.dart';

//Максимальная и минимальная длина имени
const int userNameMin = 1;
const int userNameMax = 100;

class AccountPage extends StatelessWidget {
  final GlobalKey<DisplayNameFormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Настройки аккаунта"),
        actions: <Widget>[
          PopupMenuButton(
            tooltip: "Help",
            icon: Icon(
              Icons.help,
              color: Colors.black,
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                child: Text("\nЭто страница Вашего профиля.\n"
                    "\nВы можете поменять свое имя, посмотреть количество "
                    "посещенных Вами мест, написанных отзывов "
                    "и выйти либо удалить аккаунт.\n"),
              ),
            ],
          )
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => formKey.currentState?.formFocus?.unfocus(),
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(16.0),
                child: FutureBuilder(
                  future: SignIn.auth.currentUser(),
                  builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
                    if (snapshot.hasData) {
                      return CircleAvatar(
                        backgroundImage: NetworkImage(snapshot.data.photoUrl),
                        radius: 64,
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
              ),
              DisplayNameForm(key: formKey),
              SizedBox(height: 32.0),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(children: [
                      StreamBuilder<List<String>>(
                        stream: Database.visitedByUser(
                            Account.currentAccount, context),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(snapshot.data.length.toString(),
                                textScaleFactor: 2.0);
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      ),
                      Text("Посещенные места"),
                    ]),
                    Column(children: [
                      StreamBuilder(
                        stream: Account.getReviewsForUser(context),
                        builder:
                            (context, AsyncSnapshot<List<Review>> snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data.length.toString(),
                              textScaleFactor: 2.0,
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      ),
                      Text("Отзывов написано"),
                    ]),
                  ]),
              Spacer(),
              OutlineButton(
                onPressed: () => signOut(context),
                borderSide: BorderSide(color: Colors.grey),
                child: Text("Выйти из профиля"),
              ),
              RaisedButton(
                onPressed: () => handleDeleteButton(context),
                textColor: Theme.of(context).colorScheme.onError,
                color: Theme.of(context).errorColor,
                child: Text("Удалить профиль"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleDeleteButton(BuildContext context) async {
    bool confirmed = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Вы уверены?"),
        content: Text("Все пины и отзывы связанные с вами будут удалены."),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Отмена"),
          ),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            textColor: Theme.of(context).errorColor,
            child: Text("Удалить"),
          )
        ],
      ),
    );

    if (confirmed) {
      deleteAccount(context);
    }
  }
}

class DisplayNameForm extends StatefulWidget {
  DisplayNameForm({Key key}) : super(key: key);

  @override
  State<DisplayNameForm> createState() => DisplayNameFormState();
}

class DisplayNameFormState extends State<DisplayNameForm> {
  FocusNode formFocus = FocusNode();

  GlobalKey<FormFieldState> key = GlobalKey();
  TextEditingController controller;

  bool pending = false;

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((user) {
      setState(() {
        controller = TextEditingController(text: user.displayName);
      });
    });

    super.initState();
  }

  void submitValue(value) {
    FirebaseAuth.instance.currentUser().then((user) {
      String oldDisplayName = user.displayName;
      Account.updateUserName(value);

      setState(() => pending = false);

      SnackBar snackBar = SnackBar(
        content: Text("Ваше имя было изменено"),
        action: SnackBarAction(
          label: "Отменить",
          onPressed: () {
            Account.updateUserName(oldDisplayName);
            setState(() {
              controller.text = oldDisplayName;
            });
          },
        ),
      );
      Scaffold.of(context).showSnackBar(snackBar);

      formFocus.unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: key,
      controller: controller,
      focusNode: formFocus,
      decoration: InputDecoration(
        icon: Icon(Icons.person),
        labelText: "Ваше имя",
        hintText: "Напишите свое имя",
        suffixIcon: Visibility(
          child: IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              formFocus.unfocus();
              key.currentState.save();
            },
          ),
          visible: pending,
        ),
      ),
      onChanged: (_) {
        setState(() => pending = true);
      },
      onFieldSubmitted: submitValue,
      onSaved: submitValue,
      validator: validateDisplayName,
    );
  }

  String validateDisplayName(String value) {
    RegExp alphaNumRegEx = RegExp(r'^[a-zA-Z0-9]+$');

    if (!alphaNumRegEx.hasMatch(value) && value.length > 0) {
      return "Ваше имя может состоять только из букв";
    }
    if (value.length > userNameMax) {
      return "Ваше имя слишком длинное, максимальная длинна " +
          userNameMax.toString();
    }
    if (value.length < userNameMin) {
      return "Ваше имя слишком короткое, минимальная длинна " +
          userNameMin.toString();
    }
    return null;
  }
}

void deleteAccount(BuildContext context) {
  ///изменил рут на тру, теперь все нормально закрывается
  FirebaseAuth.instance.currentUser().then((user) {
    user.delete();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => true);
  });
}

void signOut(BuildContext context) {
  FirebaseAuth.instance.signOut();
  SignIn().signOutGoogle();

  ///изменил рут на тру, теперь при перезаходе пины активны
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => true);
}
