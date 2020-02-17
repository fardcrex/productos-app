import 'package:producto_udemy/src/providers/usuario_provider.dart';
import 'package:producto_udemy/src/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:producto_udemy/src/bloc/provider.dart';
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usuarioProvider = UsuarioProvider();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _auth.onAuthStateChanged.listen((onData) {
      print("onData");
      if (onData != null)
        print(onData.email);
      else
        print(onData);
    });
  }

  @override
  Widget build(BuildContext context) {
    print("here");
    return Scaffold(
        body: Stack(
      children: <Widget>[
        _crearFondo(context),
        _loginForm(context),
      ],
    ));
  }

  Widget _loginForm(BuildContext context) {
    final bloc = Provider.of(context);
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SafeArea(
            child: Container(
              height: 140.0,
            ),
          ),
          Container(
            width: size.width * 0.80,
            margin: EdgeInsets.only(top: 50.0,bottom: 25),
            padding: EdgeInsets.symmetric(vertical: 35.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3.0,
                      offset: Offset(0.0, 5.0),
                      spreadRadius: 3.0)
                ]),
            child: Column(
              children: <Widget>[
                Text('Ingreso', style: TextStyle(fontSize: 20.0)),
                SizedBox(height: 30.0),
                _crearEmail(bloc),
                SizedBox(height: 30.0),
                _crearPassword(bloc),
                SizedBox(height: 30.0),
                _crearBoton(bloc),
                SizedBox(height: 10.0),
                Container(
                  width: 70,
                  child: _cargando ? Text(_mensajeLoadingEmail) : Text(""),
                )
              ],
            ),
          ),
          Container(
            //padding: const EdgeInsets.symmetric(vertical: 16.0,horizontal: 5.0),
            alignment: Alignment.center,
            child: RaisedButton.icon(
              onPressed: () async {
                _cargando = true;
                loading(modoDeLogueo: Modo.google);
                Map info = await usuarioProvider.signInWithGoogle();
                _cargando = false;
                if (info['ok']) {
                  Navigator.pushReplacementNamed(context, 'home');
                } else {
                  mostrarAlerta(context, info['mensaje']);
                }
              },
              icon: Container(
                margin: const EdgeInsets.symmetric(vertical: 7.0),
                width: 30,
                child: Image.asset("assets/google_logo.png")),
              label: const Text('Sign in with Google'),
            ),
          ),
          SizedBox(height: 8.0),
          FlatButton(
              child: Text("Crear nueva cuenta"),
              onPressed: () {
                bloc.changeEmail(null);
                bloc.changePassword(null);
                Navigator.pushReplacementNamed(context, 'registro');
              }),
        
          Container(
            width: 75,
            child: _cargando ? Text(_mensajeLoadingGoogle) : Text(""),
          ),
          SizedBox(height: 60.0),
          /* FlatButton(
              child: Text("Otro inicio sesión"),
              onPressed: () {
                Navigator.pushNamed(context, 'otrosLogin');
              }), */
        ],
      ),
    );
  }

  Widget _crearEmail(LoginBloc bloc) {
    return StreamBuilder(
      stream: bloc.emailStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        print(snapshot.data);
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                icon: Icon(Icons.alternate_email, color: Colors.deepPurple),
                hintText: 'ejemplo@correo.com',
                labelText: 'Correo electrónico',
                counterText: snapshot.data,
                errorText: snapshot.error),
            onChanged: bloc.changeEmail,
          ),
        );
      },
    );
  }

  Widget _crearPassword(LoginBloc bloc) {
    return StreamBuilder(
      stream: bloc.passwordStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            obscureText: true,
            decoration: InputDecoration(
                icon: Icon(Icons.lock_outline, color: Colors.deepPurple),
                labelText: 'Contraseña',
                counterText: snapshot.data,
                errorText: snapshot.error),
            onChanged: bloc.changePassword,
          ),
        );
      },
    );
  }

  Widget _crearBoton(LoginBloc bloc) {
    // formValidStream
    // snapshot.hasData
    //  true ? algo si true : algo si false

    return StreamBuilder(
      stream: bloc.formValidStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return RaisedButton(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0),
              child: Text('Ingresar'),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            elevation: 0.0,
            color: Colors.deepPurple,
            textColor: Colors.white,
            onPressed: snapshot.hasData ? () => _login(bloc, context) : null);
      },
    );
  }

  bool _cargando = false;
  String _mensajeLoadingEmail = "";
  String _mensajeLoadingGoogle = "";
  _login(LoginBloc bloc, BuildContext context) async {
    print('================');
    print('Email: ${bloc.email}');
    print('Password: ${bloc.password}');
    print('================');
    _cargando = true;

    loading(modoDeLogueo: Modo.email);

    Map info = await usuarioProvider.login(bloc.email, bloc.password);
    _cargando = false;
    if (info['ok']) {
      Navigator.pushReplacementNamed(context, 'home');
    } else {
      mostrarAlerta(context, info['mensaje']);
    }
  }

  loading({Modo modoDeLogueo}) async {
    while (_cargando) {
      await Future.delayed(Duration(milliseconds: 500));
      if (modoDeLogueo == Modo.email) _mensajeLoadingEmail = "Cargando";
      if (modoDeLogueo == Modo.google) _mensajeLoadingGoogle = "Cargando";
      if (_cargando) setState(() {});
      await Future.delayed(Duration(milliseconds: 500));
      if (modoDeLogueo == Modo.email) _mensajeLoadingEmail = "Cargando.";
      if (modoDeLogueo == Modo.google) _mensajeLoadingGoogle = "Cargando.";
      if (_cargando) setState(() {});
      await Future.delayed(Duration(milliseconds: 500));
      if (modoDeLogueo == Modo.email) _mensajeLoadingEmail = "Cargando..";
      if (modoDeLogueo == Modo.google) _mensajeLoadingGoogle = "Cargando..";
      if (_cargando) setState(() {});
      await Future.delayed(Duration(milliseconds: 500));
      if (modoDeLogueo == Modo.email) _mensajeLoadingEmail = "Cargando...";
      if (modoDeLogueo == Modo.google) _mensajeLoadingGoogle = "Cargando...";
      if (_cargando) setState(() {});
    }
  }

  Widget _crearFondo(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final fondoModaro = Container(
      height: size.height * 0.35,
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: <Color>[
        Color.fromRGBO(63, 63, 156, 1.0),
        Color.fromRGBO(90, 70, 178, 1.0)
      ])),
    );

    final circulo = Container(
      width: 100.0,
      height: 100.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.0),
          color: Color.fromRGBO(255, 255, 255, 0.05)),
    );

    return Stack(
      children: <Widget>[
        fondoModaro,
        Positioned(top: 90.0, left: 30.0, child: circulo),
        Positioned(top: -40.0, right: -30.0, child: circulo),
        Positioned(bottom: -50.0, right: -10.0, child: circulo),
        Positioned(bottom: 120.0, right: 20.0, child: circulo),
        Positioned(bottom: -50.0, left: -20.0, child: circulo),
        Container(
          padding: EdgeInsets.only(top: 50.0),
          child: Column(
            children: <Widget>[
              Icon(Icons.person_pin_circle, color: Colors.white, size: 100.0),
              SizedBox(height: 10.0, width: double.infinity),
              Text('Pool Bocangel',
                  style: TextStyle(color: Colors.white, fontSize: 25.0))
            ],
          ),
        )
      ],
    );
  }
}

enum Modo { email, google }
