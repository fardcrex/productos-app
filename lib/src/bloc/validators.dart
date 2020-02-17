import 'dart:async';

import 'package:producto_udemy/src/models/producto_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Validators {
  final validarEmail = StreamTransformer<String, String>.fromHandlers(
      handleData: (email, sink) async {
    //await Future.delayed(Duration(seconds: 3));
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (email == null) {
      sink.add("");
      return null;
    }
    if (regExp.hasMatch(email)) {
      sink.add(email);
    } else {
      sink.addError('Email no es correcto');
    }
  });

  final validarPassword = StreamTransformer<String, String>.fromHandlers(
      handleData: (password, sink) {
    if (password == null) {
      sink.add("");
      return null;
    }

    if (password.length >= 6) {
      sink.add(password);
    } else {
      sink.addError('Más de 6 caracteres por favor');
    }
  });


  // A cada producto le asociamos un usuario obtenido del cache de firestore
  final productosConUsuario =
      StreamTransformer<QuerySnapshot, List<Map>>.fromHandlers(
          handleData: (convert, sink) async {
    final List<Map> array = [];

    for (var document in convert.documents) {
     
      Firestore.instance
          .collection('usuarios')
          .document(document['usu'])
          .get(source: Source.cache)
          .then((usuario) {
        final mapa = {
          "usuario": usuario.data,
          "producto": ProductoModel(
              publico: document['publico'] ?? document['disponible'] ?? false,
              id: document.documentID,
              fotoUrl: document['url'],
              titulo: document['titulo'],
              fecha: document['fecha'],
              valor: document['precio'].toDouble())
        };
        array.add(mapa);
        array.sort(
            ((a, b) => (b["producto"].fecha.compareTo(a["producto"].fecha))));
       
        sink.add(array);
      }).catchError((onError) {
        print(onError);
      });
    }
  });
}
