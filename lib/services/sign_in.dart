import 'package:coworking/models/account.dart';
import 'package:coworking/services/database_map.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignIn {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if (googleSignInAccount == null) return null;
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await auth.signInWithCredential(credential);
    final User? user = authResult.user;

    if (user != null) {
      assert(!user.isAnonymous);
      // assert(await user.getIdToken() != null);

      final User? currentUser = auth.currentUser;
      assert(user.uid == currentUser!.uid);

      ///периодически токен меняется, нужно обновлять
      Account.currentAccount = Account.fromFirebaseUser(user);
      Account.currentAccount!.notifyToken = await _fcm.getToken();
      print(Account.currentAccount!.notifyToken);
      print("NOTIFY");
      if (authResult.additionalUserInfo!.isNewUser) {
        DatabaseMap.addUserToDatabase(Account.currentAccount);
      } else {
        DatabaseMap.updateUserToken(Account.currentAccount!.notifyToken);
      }
      return user;
    }
    return null;
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();
    print("User Signed Out");
  }
}
