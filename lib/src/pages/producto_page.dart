import 'dart:io';
import 'dart:typed_data';

import 'package:producto_udemy/src/providers/provider_imagen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path/path.dart' as Path;
import 'package:producto_udemy/src/models/producto_model.dart';
import 'package:producto_udemy/src/providers/productos_provider.dart';
import 'package:producto_udemy/src/utils/utils.dart' as utils;
import 'package:path_provider/path_provider.dart';



class ProductoPage extends StatefulWidget {
  @override
  _ProductoPageState createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final productoProvider = new ProductosProvider();

  ProductoModel producto = new ProductoModel();
  bool _guardando = false;
  bool _hayURL = false;
  File foto;

  @override
  Widget build(BuildContext context) {
    final ProductoModel prodData = ModalRoute.of(context).settings.arguments;
    if (prodData != null) {
      producto = prodData;
      if (producto.fotoUrl != null && foto == null)
        _hayURL = true;
      else
        _hayURL = false;
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Producto'),
        actions: <Widget>[
          foto == null && producto.fotoUrl == null
              ? Container()
              : IconButton(
                  icon: Icon(Icons.photo_size_select_small),
                  onPressed: _editarFoto),
          IconButton(
            icon: Icon(Icons.photo_size_select_actual),
            onPressed: _seleccionarFoto,
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: _tomarFoto,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                _mostrarFoto(),
                _crearNombre(),
                _crearPrecio(),
                _crearDisponible(),
                _crearBoton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _crearNombre() {
    return TextFormField(
      initialValue: producto.titulo,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(labelText: 'Producto'),
      onSaved: (value) => producto.titulo = value,
      validator: (value) {
        if (value.length < 3) {
          return 'Ingrese el nombre del producto';
        } else {
          return null;
        }
      },
    );
  }

  Widget _crearPrecio() {
    return TextFormField(
      initialValue: producto.valor.toString(),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: 'Precio'),
      onSaved: (value) => producto.valor = double.parse(value),
      validator: (value) {
        if (utils.isNumeric(value)) {
          return null;
        } else {
          return 'Sólo números';
        }
      },
    );
  }

  Widget _crearDisponible() {
    return SwitchListTile(
      value: producto.publico,
      title: Text('Público'),
      activeColor: Colors.deepPurple,
      onChanged: (value) => setState(() {
        producto.publico = value;
      }),
    );
  }

  Widget _crearBoton() {
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: Colors.deepPurple,
      textColor: Colors.white,
      label: Text('Guardar'),
      icon: Icon(Icons.save),
      onPressed: (_guardando) ? null : _submit,
    );
  }

  void _submit() async {
    if (!formKey.currentState.validate()) return;

    formKey.currentState.save();
    setState(() {
      _guardando = true;
    });

    if (foto != null) {
      final fileName = "imagen-${DateTime.now().millisecondsSinceEpoch}.jpg";
      producto.fotoUrl = await subirImagen(foto, fileName);
    }

    if (producto.id == null) {
      producto.fecha = DateTime.now().millisecondsSinceEpoch;
      productoProvider.crearProducto(producto);
    } else {
      try {
        await productoProvider.editarProducto(producto);
      } catch (e) {
        print(e);
        return;
      }
    }

    setState(() {
      _guardando = false;
    });
    mostrarSnackbar('Registro guardado');

    Navigator.pop(context);
  }

  void mostrarSnackbar(String mensaje) {
    final snackbar = SnackBar(
      content: Text(mensaje),
      duration: Duration(milliseconds: 1500),
    );

    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  Widget _mostrarFoto() {
    if (_hayURL) {
      return FadeInImage(
        image: NetworkImage(producto.fotoUrl),
        placeholder: AssetImage('assets/imagenCargando.gif'),
        height: 300.0,
        fit: BoxFit.contain,
      );
    } else {
      return FadeInImage(
        image: foto == null
            ? AssetImage('assets/imagenEmpty.jpg')
            : FileImage(foto),
        placeholder: AssetImage('assets/imagenCargando.gif'),
        height: 300.0,
        fit: BoxFit.contain,
      );
    }
  }

  _seleccionarFoto() async {
    _procesarImagen(ImageSource.gallery);
  }

  _tomarFoto() async {
    _procesarImagen(ImageSource.camera);
  }

  _procesarImagen(ImageSource origen) async {
    foto = await ImagePicker.pickImage(source: origen, imageQuality: 40);

    if (foto != null) {
      _hayURL = false;
    }

    setState(() {});
  }

  _editarFoto() async {
    File fotoRetornado = await _getFile(foto);
    File fotoeditada = await ImageCropper.cropImage(
        sourcePath: fotoRetornado.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Editar',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));

    if (fotoeditada != null) {
      _hayURL = false;
      foto = fotoeditada;
    }
    setState(() {});
  }

  Future<File> _getFile(File file) async {
    if (file != null) return file;//Si la imagen ya esta cargada en local devolvera esa misma imagen
    if (producto.fotoUrl != null) {//En todo caso se descargara la imagen desde la web para pode editarla

      final directory = await getTemporaryDirectory();
      final fileName  = Path.basename(producto.fotoUrl);
      final path      = Path.join(directory.path, fileName);

      final fileReturn = decargarImagenFromPath(producto.fotoUrl,path);
      return fileReturn;
    }
    return null;
  }

  Future<File> decargarImagenFromPath(String url, String path) async {
    final request    = await HttpClient().getUrl(Uri.parse(url));
    final response   = await request.close();
    Uint8List bytes  = await consolidateHttpClientResponseBytes(response);

    final fileReturn = await File(path).writeAsBytes(bytes);
    return fileReturn;
  }
}
