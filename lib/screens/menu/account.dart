import 'package:coworking/models/account.dart';
import 'package:coworking/services/database_account.dart';
import 'package:coworking/services/database_pin.dart';
import 'package:coworking/models/review.dart';
import 'package:coworking/services/database_review.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:coworking/screens/login/login_widget.dart';

import 'package:coworking/services/sign_in.dart';

//Максимальная и минимальная длина имени
const int userNameMin = 1;
const int userNameMax = 100;

class AccountScreen extends StatelessWidget {
  final GlobalKey<DisplayNameFormState> formKey = GlobalKey();

  AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Настройки аккаунта"),
        actions: <Widget>[
          PopupMenuButton(
            tooltip: "Help",
            icon: const Icon(
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
        onTap: () => formKey.currentState?.formFocus.unfocus(),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(16.0),
                child: FutureBuilder(
                  future: Future.value(SignIn.auth.currentUser),
                  builder: (context, AsyncSnapshot<User?> snapshot) {
                    if (snapshot.hasData) {
                      return CircleAvatar(
                        backgroundImage: NetworkImage(snapshot.data!.photoURL!),
                        radius: 64,
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              ),
              DisplayNameForm(key: formKey),
              const SizedBox(height: 32.0),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(children: [
                      StreamBuilder<List<String>>(
                        stream: DatabasePin.visitedByUser(
                            Account.currentAccount as Account, context),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(snapshot.data!.length.toString(),
                                textScaleFactor: 2.0);
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                      const Text("Посещенные места"),
                    ]),
                    Column(children: [
                      StreamBuilder(
                        stream: DatabaseReview.reviewsOfUser(
                            Account.currentAccount!, context),
                        builder:
                            (context, AsyncSnapshot<List<Review>> snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data!.length.toString(),
                              textScaleFactor: 2.0,
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                      const Text("Отзывов написано"),
                    ]),
                  ]),
              const Spacer(),
              OutlinedButton(
                onPressed: () => signOut(context),
                child: const Text("Выйти из профиля"),
              ),
              ElevatedButton(
                onPressed: () => handleDeleteButton(context),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).errorColor),
                ),
                child: const Text("Удалить профиль"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleDeleteButton(BuildContext context) async {
    bool? confirmed = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Вы уверены?"),
        content: const Text(
            "Все ваши встречи будут удалены, но пины и отзывы останутся."),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Отмена"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Удалить", style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );

    if (confirmed != null) {
      deleteAccount(context);
    }
  }
}

class DisplayNameForm extends StatefulWidget {
  const DisplayNameForm({Key? key}) : super(key: key);

  @override
  State<DisplayNameForm> createState() => DisplayNameFormState();
}

class DisplayNameFormState extends State<DisplayNameForm> {
  FocusNode formFocus = FocusNode();

  GlobalKey<FormFieldState> key = GlobalKey();
  late TextEditingController controller;

  bool pending = false;

  @override
  void initState() {
    controller = TextEditingController(
        text: FirebaseAuth.instance.currentUser!.displayName);

    super.initState();
  }

  void submitValue(value) {
    String? oldDisplayName = FirebaseAuth.instance.currentUser!.displayName;
    DatabaseAccount.updateUsername(value);

    setState(() => pending = false);

    SnackBar snackBar = SnackBar(
      content: const Text("Ваше имя было изменено"),
      action: SnackBarAction(
        label: "Отменить",
        onPressed: () {
          DatabaseAccount.updateUsername(oldDisplayName!);
          setState(() {
            controller.text = oldDisplayName;
          });
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    formFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: key,
      controller: controller,
      focusNode: formFocus,
      decoration: InputDecoration(
        icon: const Icon(Icons.person),
        labelText: "Ваше имя",
        hintText: "Напишите свое имя",
        suffixIcon: Visibility(
          child: IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              formFocus.unfocus();
              key.currentState!.save();
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

  String? validateDisplayName(String? value) {
    RegExp alphaNumRegEx = RegExp(r'^[a-zA-Z0-9]+$');

    if (!alphaNumRegEx.hasMatch(value!) && value.isNotEmpty) {
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

void deleteAccount(BuildContext context) async {
  //изменил рут на тру, теперь все нормально закрывается
  var currentUser = FirebaseAuth.instance.currentUser;
  DatabaseAccount.deleteUser(Account.currentAccount!);
  await currentUser!.delete();
  SignIn().signOutGoogle();
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => true);
}

void signOut(BuildContext context) {
  FirebaseAuth.instance.signOut();
  SignIn().signOutGoogle();
  Account.currentAccount = null;
  //изменил рут на тру, теперь при перезаходе пины активны
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => true);
}
