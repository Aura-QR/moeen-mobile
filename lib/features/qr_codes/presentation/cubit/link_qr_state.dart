import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:equatable/equatable.dart';

class LinkQrState extends Equatable {
  final String url;
  final String caption;
  final ui.Image? logo;
  final Uint8List? logoBytes;
  final bool isValid;
  final bool hasEdited;

  const LinkQrState({
    this.url = '',
    this.caption = '',
    this.logo,
    this.logoBytes,
    this.isValid = false,
    this.hasEdited = false,
  });

  LinkQrState copyWith({
    String? url,
    String? caption,
    ui.Image? logo,
    Uint8List? logoBytes,
    bool? isValid,
    bool? hasEdited,
    bool clearLogo = false,
  }) {
    return LinkQrState(
      url: url ?? this.url,
      caption: caption ?? this.caption,
      logo: clearLogo ? null : (logo ?? this.logo),
      logoBytes: clearLogo ? null : (logoBytes ?? this.logoBytes),
      isValid: isValid ?? this.isValid,
      hasEdited: hasEdited ?? this.hasEdited,
    );
  }

  @override
  List<Object?> get props => [
        url,
        caption,
        logo,
        logoBytes,
        isValid,
        hasEdited,
      ];
}
