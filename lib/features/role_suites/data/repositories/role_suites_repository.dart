import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/api_response_handler.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/role_suites/data/models/role_suite_models.dart';

/// L1 «حقائب الأدوار» catalogue and document templates (DOCUMENTS_API.md § 13).
class RoleSuitesRepository {
  Future<Either<Failure, List<RoleSuiteSummary>>> getRoles() => handleApiResponse(
        DioHelper.getData(url: rolesToolApi),
        parseRoleSuitesList,
      );

  Future<Either<Failure, RoleSuiteDetailModel>> getRole(String role) => handleApiResponse(
        DioHelper.getData(url: roleSuiteApi(role)),
        (data) => RoleSuiteDetailModel.fromJson(
          data is Map ? Map<String, dynamic>.from(data) : const {},
          fallbackKey: role,
        ),
      );

  Future<Either<Failure, RoleDocumentTemplateModel>> getDocument(String role, String doc) => handleApiResponse(
        DioHelper.getData(url: roleDocumentApi(role, doc)),
        (data) => RoleDocumentTemplateModel.fromJson(
          data is Map ? Map<String, dynamic>.from(data) : const {},
          fallbackRole: role,
          fallbackDoc: doc,
        ),
      );
}
