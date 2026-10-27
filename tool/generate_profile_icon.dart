import 'dart:io';

import 'package:image/image.dart' as image;

/// Crea el recurso cuadrado del icono sin deformar ni cambiar la foto original.
void main() {
  final original = image.decodeImage(
    File('assets/images/2x2.jpg').readAsBytesSync(),
  );
  if (original == null) {
    throw const FormatException('No se pudo leer la foto del autor.');
  }
  final square = image.copyResizeCropSquare(
    image.bakeOrientation(original),
    size: 512,
  );
  final output = File('assets/icon/profile.png');
  output.parent.createSync(recursive: true);
  output.writeAsBytesSync(image.encodePng(square));
}
