import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/api_response_handler.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';

/// «فصولي»: the teacher's classes and their student names (CLASSES_API.md).
class ClassesRepository {
  /// Sorted by name, without the names.
  Future<Either<Failure, List<SchoolClassModel>>> getClasses() => handleApiResponse(
        DioHelper.getData(url: classesApi),
        (data) => (data as List).whereType<Map<String, dynamic>>().map(SchoolClassModel.fromJson).toList(),
      );

  Future<Either<Failure, SchoolClassModel>> getClass(int id) => handleApiResponse(
        DioHelper.getData(url: classApi(id)),
        _class,
      );

  Future<Either<Failure, SchoolClassModel>> createClass(SchoolClassModel schoolClass) => handleApiResponse(
        DioHelper.postData(url: classesApi, data: schoolClass.toJson()),
        _class,
      );

  /// Replaces the whole student list with [SchoolClassModel.students].
  Future<Either<Failure, SchoolClassModel>> updateClass(int id, SchoolClassModel schoolClass) =>
      handleApiResponse(
        DioHelper.putData(url: classApi(id), data: schoolClass.toJson()),
        _class,
      );

  /// Deletes the class and its names permanently.
  Future<Either<Failure, Unit>> deleteClass(int id) => handleApiResponse(
        DioHelper.deleteData(url: classApi(id)),
        (_) => unit,
      );

  /// Reads the names from an Excel or CSV file. Nothing is saved.
  Future<Either<Failure, List<String>>> importNames(DevicePickedFile file) => handleApiResponse(
        DioHelper.postData(
          url: classesImportApi,
          data: FormData.fromMap({'file': MultipartFile.fromBytes(file.bytes, filename: file.name)}),
        ),
        (data) {
          final names = (data as Map<String, dynamic>)['names'];
          return names is List ? names.map((name) => name.toString()).toList() : const <String>[];
        },
      );

  static SchoolClassModel _class(dynamic data) => SchoolClassModel.fromJson(data as Map<String, dynamic>);
}
