import 'package:producto_udemy/src/models/producto_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductosProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  crearProducto(ProductoModel producto) async {
    final FirebaseUser currentUser = await _auth.currentUser();
    final productoF = await Firestore.instance.collection('productos').add({
      'publico': producto.publico,
      'precio': producto.valor,
      'titulo': producto.titulo,
      'url': producto.fotoUrl,
      'usu': currentUser.uid,
      'fecha': producto.fecha,
    });
    print(productoF.documentID);
    Firestore.instance
        .collection('usuario-producto')
        .document(currentUser.uid)
        .collection('productos')
        .document(productoF.documentID)
        .setData({
      'publico': producto.publico,
      'precio': producto.valor,
      'titulo': producto.titulo,
      'fecha': producto.fecha,
      'url': producto.fotoUrl,
    }).then((onValue) {});
  }

  final _instancia = Firestore.instance;
  FirebaseUser _currentUser;

  editarProducto(ProductoModel producto) async {
    _currentUser = await _auth.currentUser();
    
    _updateCollectionProducto(producto);
    _updateCollectionUsuarioProducto(producto);
  }
  

  _updateCollectionUsuarioProducto(ProductoModel producto) {
    _instancia
        .collection('usuario-producto')
        .document(_currentUser.uid)
        .collection('productos')
        .document(producto.id)
        .setData({
      'publico': producto.publico,
      'precio': producto.valor,
      'titulo': producto.titulo,
      'fecha': producto.fecha,
      'url': producto.fotoUrl,
    }).then((onValue) {}, onError: (e) {
      print("error: $e");
    });
  }

  _updateCollectionProducto(ProductoModel producto) {
    _instancia.collection('productos').document(producto.id).updateData({
      'publico': producto.publico,
      'precio': producto.valor,
      'titulo': producto.titulo,
      'url': producto.fotoUrl,
      'fecha': producto.fecha,
    }).then((onValue) {}, onError: (e) {
      print("error: $e");
    });
  }


  eliminarProducto(String idDocument) async {
    final FirebaseUser currentUser = await _auth.currentUser();
    Firestore.instance
        .collection("productos")
        .document(idDocument)
        .delete()
        .then((onValue) {}, onError: (e) {
      print("error1: $e");
    });
    Firestore.instance
      ..collection('usuario-producto')
          .document(currentUser.uid)
          .collection('productos')
          .document(idDocument)
          .delete()
          .then((onValue) {}, onError: (e) {
        print("error2: $e");
      });
  }
}
