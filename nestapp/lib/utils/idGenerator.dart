import 'dart:math';

String generateID({String? prefix, String? suffix}) {
  final random = Random();
  const characters =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  // Generar una cadena aleatoria de 8 caracteres
  String randomString = String.fromCharCodes(
    List.generate(
        8, (index) => characters.codeUnitAt(random.nextInt(characters.length))),
  );

  // Concatenar el prefijo y el sufijo si se proporcionan
  String result = (prefix ?? '') + randomString + (suffix ?? '');

  return result;
}
