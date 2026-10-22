import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moean/core/models/upload_models.dart';

/// Picks a file from the camera, the gallery or the files app.
class DeviceFilePicker {
  DeviceFilePicker({ImagePicker? imagePicker})
      : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  /// Returns null when the teacher cancels.
  Future<DevicePickedFile?> pick(DeviceFileSource source) async {
    if (source == DeviceFileSource.pdf) return _pickPdf();

    // With imageQuality set, iOS converts HEIC to JPEG, and 2000px keeps
    // phone photos well under the 10 MB limit.
    final image = await _imagePicker.pickImage(
      source: source == DeviceFileSource.camera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 2000,
    );
    if (image == null) return null;

    return DevicePickedFile(
      bytes: await image.readAsBytes(),
      name: image.name,
      mime: DevicePickedFile.mimeFromName(image.name),
    );
  }

  /// An Excel or CSV sheet, e.g. a class list to import. Its [DevicePickedFile.mime]
  /// is null: only the extension matters to the import endpoint.
  Future<DevicePickedFile?> pickSpreadsheet() => _pickFile(const ['xlsx', 'xls', 'csv']);

  Future<DevicePickedFile?> _pickPdf() => _pickFile(const ['pdf']);

  Future<DevicePickedFile?> _pickFile(List<String> extensions) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      withData: true,
    );
    final file = result?.files.single;
    if (file == null || file.bytes == null) return null;

    return DevicePickedFile(
      bytes: file.bytes!,
      name: file.name,
      mime: DevicePickedFile.mimeFromName(file.name),
    );
  }
}
