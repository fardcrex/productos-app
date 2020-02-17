
import 'package:producto_udemy/src/bloc/provider.dart';
import 'package:producto_udemy/src/pages/home_page.dart';
import 'package:producto_udemy/src/pages/login_page.dart';
import 'package:producto_udemy/src/pages/producto_page.dart';
import 'package:producto_udemy/src/pages/publicProductos.dart';
import 'package:producto_udemy/src/preferencias_usuario/preferencias.dart';

import 'package:flutter/material.dart';

import 'src/pages/registro_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = new PreferenciasUsuario();
  await prefs.initPrefs();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  final _prefs = new PreferenciasUsuario();
  @override
  Widget build(BuildContext context) {
    print(_prefs.uid);
    String initialRoute;
    if(_prefs.uid == null || _prefs.uid == ""){
      initialRoute = 'login';
    }else{
      initialRoute = 'home';
    }
    return Provider(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Material App',
        initialRoute: initialRoute,
        routes: {
          'login': (BuildContext context) => LoginPage(),
          'home': (BuildContext context) => HomePage(),
          'producto': (BuildContext context) => ProductoPage(),
          'registro': (BuildContext context) => RegistroPage(),
          'editPhoto': (BuildContext context) => PublicProductos(),
        },
        theme: ThemeData(
          primaryColor: Colors.deepPurple,
        ),
      ),
    );
  }
}

