import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/api_response_handler.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/thank_you_certificates/data/models/certificates_catalogue_model.dart';

/// The read-only catalogue the T3 form is built from.
class CertificatesRepository {
  /// The audiences, the 8 reasons with their default texts, and the 6 designs.
  Future<Either<Failure, CertificatesCatalogueModel>> getCatalogue() => handleApiResponse(
    DioHelper.getData(url: certificatesToolApi),
    (data) => CertificatesCatalogueModel.fromJson(data as Map<String, dynamic>),
  );
}
