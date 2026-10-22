import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/api_response_handler.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/grade_analysis/data/models/grade_analysis_result.dart';
import 'package:moean/features/grade_analysis/data/models/grade_options_model.dart';
import 'package:moean/features/grade_analysis/data/models/grade_sheet_import.dart';

/// T7 «تحليل نتائج الطلاب» (GRADE_ANALYSIS_API.md). Saving goes through the documents API.
class GradeAnalysisRepository {
  /// The default pass percentage and levels, and the limits.
  Future<Either<Failure, GradeOptionsModel>> getOptions() => handleApiResponse(
    DioHelper.getData(url: gradesToolApi),
    (data) => GradeOptionsModel.fromJson(data as Map<String, dynamic>),
  );

  /// The numbers for [input] (the document's `input`). Nothing is saved.
  Future<Either<Failure, GradeAnalysisResult>> analyze(Map<String, dynamic> input) => handleApiResponse(
    DioHelper.postData(url: gradesAnalyzeApi, data: input),
    (data) => GradeAnalysisResult.fromJson(data as Map<String, dynamic>),
  );

  /// Names and grades from an Excel or CSV sheet, for review. Nothing is saved.
  Future<Either<Failure, GradeSheetImport>> importSheet(DevicePickedFile file) => handleApiResponse(
    DioHelper.postData(
      url: gradesImportApi,
      data: FormData.fromMap({'file': MultipartFile.fromBytes(file.bytes, filename: file.name)}),
    ),
    (data) => GradeSheetImport.fromJson(data as Map<String, dynamic>),
  );

  /// «حذف كل بيانات التحليل»: every saved analysis, with its files, now.
  /// Returns how many were deleted.
  Future<Either<Failure, int>> deleteAll() => handleApiResponse(
    DioHelper.deleteData(url: gradesDataApi),
    (data) => int.tryParse('${(data as Map<String, dynamic>)['deleted']}') ?? 0,
  );
}
