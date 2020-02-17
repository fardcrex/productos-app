import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final vara = IconButton(
            icon: Icon(Icons.cloud),
            onPressed: () async {
               print("//Traer por stream");
              Firestore.instance
                  .collection('productos')
                  .where("disponible", isEqualTo: true)
                  .orderBy("precio")
                  .snapshots()
                  .listen((data) =>
                      data.documents.forEach((doc) => print(doc["titulo"])));

              print("//Traer uno espicifico");
              Firestore.instance
                  .collection('productos')
                  .document('pedrito')
                  .get()
                  .then((DocumentSnapshot ds) {
                print('author');
                print(ds['author']);
              });

              /////////añadir y retornar
              final data1 = await Firestore.instance
                  .collection('productos')
                  .add({"data": "prueba añadir", "precio": 33.3});
              print(data1.documentID);

              await Firestore.instance
                  .collection('productos')
                  .document("pedrito")
                  .setData({'title': 'title', 'author': 'Pedro'});

              Firestore.instance
                  .collection("productos")
                  .orderBy("precio")
                  .snapshots()
                  .listen((data) {
                data.documents.forEach((doc) => print(doc["precio"]));
              });

              print("//Traer colecion consulta espicifico");
              final data2 = await Firestore.instance
                  .collection("productos")
                  .getDocuments();
              data2.documents
                  .forEach((doc) => print("titulo: " + "${doc["titulo"]}"));

              Firestore.instance
                  .collection("productos").limit(5).snapshots().listen((data) {
                data.documents.forEach((doc) => print(doc["precio"]));
              });
           
              Firestore.instance
                  .collection("productos")
                  .document("mdkhwmNem2dA823Kwe3w")
                  .snapshots()
                  .listen((data) {
                print(data);
              });

              Firestore.instance
                  .collection("usuarios")
                  .snapshots()
                  .listen((onData) {
                print(onData);
              });
            },
          );