// To parse this JSON data, do
//
//     final productoModel = productoModelFromJson(jsonString);

import 'dart:convert';

ProductoModel productoModelFromJson(String str) => ProductoModel.fromJson(json.decode(str));

String productoModelToJson(ProductoModel data) => json.encode(data.toJson());

class ProductoModel {

    String id;
    String titulo;
    double valor;
    bool publico;
    String fotoUrl;
    int fecha;

    ProductoModel({
        this.id,
        this.titulo = '',
        this.valor  = 0.0,
        this.publico = true,
        this.fotoUrl,
        this.fecha
    });

    factory ProductoModel.fromJson(Map<String, dynamic> json) => new ProductoModel(
        id         : json["id"],
        titulo     : json["titulo"],
        valor      : json["valor"],
        publico    : json["publico"],
        fotoUrl    : json["fotoUrl"],
        fecha      : json["fecha"],
    );

    Map<String, dynamic> toJson() => {
        // "id"         : id,
        "titulo"     : titulo,
        "valor"      : valor,
        "publico"    : publico,
        "fotoUrl"    : fotoUrl,
        "fecha"      : fecha,
    };
}
