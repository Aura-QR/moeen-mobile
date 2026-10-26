import 'dart:typed_data';
import 'package:equatable/equatable.dart';

class ExtractionPageModel extends Equatable {
  final Uint8List bytes;
  final String name;
  final String mime;

  const ExtractionPageModel({
    required this.bytes,
    required this.name,
    required this.mime,
  });

  bool get isPdf =>
      mime == 'application/pdf' || name.toLowerCase().endsWith('.pdf');

  int get byteSize => bytes.length;

  @override
  List<Object?> get props => [name, mime, bytes];
}
