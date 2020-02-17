//import 'package:cached_network_image/cached_network_image.dart';
import 'package:producto_udemy/src/preferencias_usuario/preferencias.dart';
import 'package:producto_udemy/src/providers/usuario_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:producto_udemy/src/models/producto_model.dart';
import 'package:producto_udemy/src/providers/productos_provider.dart';

class HomePage extends StatelessWidget {
  final productoProvider = new ProductosProvider();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void mostrarAlerta(BuildContext context, FirebaseUser currentUser) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Perfil"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(currentUser.email),
                Text(currentUser.displayName ?? ""),
                Text(currentUser.phoneNumber ?? ""),
                Container(
                  height: 200,
                  child: FadeInImage(
                    image: currentUser.photoUrl == null
                        ? AssetImage("assets/perfil.png")
                        : NetworkImage(currentUser.photoUrl),
                    placeholder: AssetImage("assets/imagenCargando.gif"),
                  ),
                )
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = UsuarioProvider();
    final _prefs = new PreferenciasUsuario();
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis productos'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_box),
            onPressed: () async {
              final FirebaseUser currentUser = await _auth.currentUser();
              mostrarAlerta(context, currentUser);
            },
          ),
          IconButton(
            icon: Icon(Icons.public),
            onPressed: () async {
              Navigator.pushNamed(context, "editPhoto");
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _prefs.uid = null;
              usuarioProvider.deslogueo();
              Navigator.pushReplacementNamed(context, "login");
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('usuario-producto')
            .document(_prefs.uid)
            .collection("productos")
            .orderBy("fecha", descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return new Text('Loading...');
            default:
              return new ListView(
                children:
                    snapshot.data.documents.map((DocumentSnapshot document) {
                  final producto = new ProductoModel(
                      publico: document['publico'] ??
                          document['disponible'] ??
                          false,
                      id: document.documentID,
                      fotoUrl: document['url'],
                      titulo: document['titulo'],
                      fecha: document['fecha'],
                      valor: document['precio'].toDouble());

                  return Dismissible(
                      key: UniqueKey(),
                      background: Container(
                        color: Colors.red,
                      ),
                      onDismissed: (dirrecion) {
                        productoProvider.eliminarProducto(document.documentID);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Color(0xffffffff),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(2.00, 3.00),
                              color: Color(0xff000000).withOpacity(0.78),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Card(
                          child: Column(
                            children: <Widget>[
                              (producto.fotoUrl == null)
                                  ? Image(
                                      height: 250,
                                      image:
                                          AssetImage('assets/imagenEmpty.jpg'),
                                    )
                                  : FadeInImage(
                                      image: NetworkImage(producto.fotoUrl),
                                      placeholder: AssetImage(
                                          'assets/imagenCargando.gif'),
                                      height: 250,
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                    ),
                              //Widget para la persistencia de imagen
                              /* CachedNetworkImage(
                                    height: 300.0,
                                      imageUrl:
                                          producto.fotoUrl,
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ), */
                              ListTile(
                                title: new Text(producto.titulo),
                                subtitle: new Text(producto.valor.toString()),
                                onTap: () => Navigator.pushNamed(
                                    context, 'producto',
                                    arguments: producto),
                                trailing: Icon(
                                  Icons.public,
                                  color: producto.publico
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ));
                }).toList(),
              );
          }
        },
      ),
      floatingActionButton: _crearBoton(context),
    );
  }

  _crearBoton(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      backgroundColor: Colors.deepPurple,
      onPressed: () {
        Navigator.pushNamed(context, 'producto');
      },
    );
  }
}
