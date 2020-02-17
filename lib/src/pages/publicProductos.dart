//import 'package:cached_network_image/cached_network_image.dart';
import 'package:producto_udemy/src/bloc/validators.dart';
import 'package:producto_udemy/src/preferencias_usuario/preferencias.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:producto_udemy/src/providers/productos_provider.dart';

class PublicProductos extends StatelessWidget with Validators {
  final productoProvider = new ProductosProvider();
  final firestoreInstancia = Firestore.instance;
  @override
  Widget build(BuildContext context) {
/*     final bloc = Provider.of(context);
    final usuarioProvider = UsuarioProvider(); */
    final _prefs = new PreferenciasUsuario();

    return Scaffold(
      appBar: AppBar(
        title: Text('Otros Poductos'),
        //   actions: getActions()
      ),
      body: StreamBuilder<List<Map>>(
        stream: firestoreInstancia
            .collection('productos')
            .where("publico", isEqualTo: true)
            .orderBy("fecha", descending: true)
            //.orderBy("fecha")
            .limit(10)
            .snapshots()
            .transform<List<Map>>(productosConUsuario),
        builder: (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
          print("STEREAM");
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return new Text('Loading...');
            default:
              return new ListView(
                children: snapshot.data.map((document) {
                  var fotoWidget;
                  var producto = document['producto'];
                  var email = document['usuario']['email'];
                  var fotoUrl = document['usuario']['fotoUrl'];

                  fotoWidget = fotoUrl == null
                      ? AssetImage("assets/perfil.png")
                      : NetworkImage(fotoUrl);
                  return Container(
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
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Row(
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundImage: fotoWidget,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(email ?? "")
                              ],
                            ),
                          ),
                          (producto.fotoUrl == null)
                              ? Image(
                                  height: 250,
                                  image: AssetImage('assets/imagenEmpty.jpg'),
                                )
                              : FadeInImage(
                                  image: NetworkImage(producto.fotoUrl),
                                  placeholder:
                                      AssetImage('assets/imagenCargando.gif'),
                                  height: 250,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                ),
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
                            trailing: Icon(
                              Icons.public,
                              color:
                                  producto.publico ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
          }
        },
      ),
    );
  } 
}
