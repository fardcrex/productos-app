import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:mime_type/mime_type.dart';
import 'package:http/http.dart' as http;


//uRL de tu servidor de imagenes example: 'https://cloudimagen.com/api/subirimagen'
final urlString =  "";

Future<String> subirImagen(File imagen, String filename) async {
  assert(urlString != "");
  var url = Uri.parse(urlString);

  final mimeType = mime(imagen.path).split('/');
  var imagenUploadRequest = http.MultipartRequest("POST", url);
  final file = await http.MultipartFile.fromPath('myFile', imagen.path,
      filename: filename, contentType: MediaType(mimeType[0], mimeType[1]));

  imagenUploadRequest.files.add(file);
  try {
    final srtreamResponse = await imagenUploadRequest.send();
    print("se envió");
    var response = await http.Response.fromStream(srtreamResponse);
    var respuestaDecodificada = json.decode(response.body);
    print(respuestaDecodificada['url']);
    return respuestaDecodificada['url'];
  } catch (e) {
    print(e);
    return null;
  }
}
