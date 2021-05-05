import 'package:coworking/models/account.dart';
import 'package:coworking/services/database_map.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignIn {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseMessaging _fcm = FirebaseMessaging();
  final GoogleSignIn googleSignIn = new GoogleSignIn(
    scopes: [
      'email',
    ],
  );

  Future<FirebaseUser> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await auth.signInWithCredential(credential);
    final FirebaseUser user = await authResult.user;

    if (user != null) {
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await auth.currentUser();
      assert(user.uid == currentUser.uid);

      Account.currentAccount = Account.fromFirebaseUser(user);
      if (authResult.additionalUserInfo.isNewUser) {
        Account.currentAccount.notifyToken = await _fcm.getToken();
        DatabaseMap.addUserToDatabase(Account.currentAccount);
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
