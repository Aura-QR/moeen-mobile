import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/qr_codes/presentation/cubit/link_qr_state.dart';

class LinkQrCubit extends Cubit<LinkQrState> {
  final DeviceFilePicker _filePicker;
  Timer? _debounceTimer;

  LinkQrCubit({DeviceFilePicker? filePicker})
      : _filePicker = filePicker ?? DeviceFilePicker(),
        super(const LinkQrState());

  static LinkQrCubit get(BuildContext context) => BlocProvider.of(context);

  static String normalizeUrl(String input) {
    var trimmed = input.trim();
    if (trimmed.isEmpty) return '';
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      trimmed = 'https://$trimmed';
    }
    return trimmed;
  }

  static bool validateUrl(String input) {
    if (input.trim().isEmpty) return false;
    final normalized = normalizeUrl(input);
    final uri = Uri.tryParse(normalized);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty &&
        (uri.host.contains('.') || uri.host == 'localhost');
  }

  void setUrl(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (isClosed) return;
      final isValid = validateUrl(value);
      final normalized = isValid ? normalizeUrl(value) : value.trim();
      emit(state.copyWith(
        url: normalized,
        isValid: isValid,
        hasEdited: true,
      ));
    });
  }

  void setCaption(String caption) {
    final trimmed =
        caption.length > 60 ? caption.substring(0, 60) : caption;
    emit(state.copyWith(caption: trimmed));
  }

  Future<void> pickLogo() async {
    final file = await _filePicker.pick(DeviceFileSource.gallery);
    if (file == null) return;

    final bytes = file.bytes;
    final codec = await ui.instantiateImageCodec(bytes);
    final frameInfo = await codec.getNextFrame();
    final image = frameInfo.image;

    emit(state.copyWith(
      logoBytes: bytes,
      logo: image,
    ));
  }

  void removeLogo() {
    emit(state.copyWith(clearLogo: true));
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
