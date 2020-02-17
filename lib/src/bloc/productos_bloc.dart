


import 'package:producto_udemy/src/models/producto_model.dart';
import 'package:rxdart/rxdart.dart';

class ProductoBloc {

  final _productosController = new BehaviorSubject<List<ProductoModel>>();
  final _cargandoController = new BehaviorSubject<bool>();



  Stream<List<ProductoModel>> get productosStream => _productosController;
  Stream<bool> get cargando => _cargandoController;

  void cargarProductos()async{
   
  }

  dispose(){
    _productosController.close();
    _cargandoController.close();
  }
}