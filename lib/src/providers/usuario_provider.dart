import 'dart:convert';
import 'package:producto_udemy/src/preferencias_usuario/preferencias.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:http/http.dart' as http;

class UsuarioProvider {
  final _prefs = new PreferenciasUsuario();
  final String _fireBaseToken = "AIzaSyC_7ZTE3Ie9jXedoLqaCj6tRr8qNAEXsp0";
  final FirebaseAuth _auth = FirebaseAuth.instance;

 /*  Future<Map<String, dynamic>> loguearse(String email, String password) async {
    final authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    final res = await http.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_fireBaseToken',
        body: json.encode(authData));

    Map<String, dynamic> decodeResp = json.decode(res.body);

    print(decodeResp);
    if (decodeResp.containsKey('idToken')) {
      _prefs.uid = decodeResp['idToken'];
      return {'ok': true, 'token': decodeResp['idToken']};
    } else {
      return {'ok': false, 'mensaje': decodeResp['error']['message']};
    }
  }

  Future<Map<String, dynamic>> nuevoUsuario(
      String email, String password) async {
    final authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };

    final res = await http.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_fireBaseToken',
        body: json.encode(authData));

    Map<String, dynamic> decodeResp = json.decode(res.body);

    print(decodeResp);
    if (decodeResp.containsKey('idToken')) {
      _prefs.uid = decodeResp['idToken'];
      return {'ok': true, 'token': decodeResp['idToken']};
    } else {
      return {'ok': false, 'mensaje': decodeResp['error']['message']};
    }
  }
 */
  
  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final credencial = (await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ));
      final user = credencial.user;
      
      final tokenResult = await user.getIdToken();
      
      _prefs.uid = user.uid;
       crearUsuarioFirestore(user);

      return {'ok': true, 'token': tokenResult.token};
    } catch (e) {
      return {'ok': false, 'mensaje': 'hubo un error ${e.message}'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final credencial = (await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ));
      final user = credencial.user;
     
      final tokenResult = await user.getIdToken();
      _prefs.uid = user.uid;    

      crearUsuarioFirestore(user);

      return {'ok': true, 'token': tokenResult.token};
    } catch (e) {
      return {'ok': false, 'mensaje': 'hubo un error ${e.message}'};
    }
  }

  deslogueo() async {
    await _auth.signOut();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
      assert(user.email != null);
      assert(user.displayName != null);
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      final tokenResult = await user.getIdToken();
      _prefs.uid = user.uid;

      crearUsuarioFirestore(user);

      return {'ok': true, 'token': tokenResult.token};
    } catch (e) {
      return {'ok': false, 'mensaje': 'hubo un error ${e.message}'};
    }
  }

  crearUsuarioFirestore(user) async {
    final data1 = await Firestore.instance
        .collection('usuarios')
        .document(user.uid)
        .get();
    if (data1.data == null) {
      await Firestore.instance
          .collection('usuarios')
          .document(user.uid)
          .setData({
        "email": user.email,
        "nombre": user.displayName,
        "telefono": user.phoneNumber,
        "fotoUrl": user.photoUrl,
        "providerId": user.uid
      });
      print("SE LOGUEO Y ENTRO");
    }
  }
}
