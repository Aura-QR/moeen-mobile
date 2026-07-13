import 'package:dartz/dartz.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/payment/data/models/payment_model.dart';

class AdminPaymentsRepository {
  Future<Either<String, Map<String, dynamic>>> getPayments({
    String? filter,
    String? search,
    int? page,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {};
      if (filter != null && filter.isNotEmpty && filter != 'all') {
        queryParameters['filter'] = filter;
      }
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }
      if (page != null) {
        queryParameters['page'] = page;
      }

      final responseEither = await DioHelper.getData(
        url: adminPaymentsApi,
        query: queryParameters,
      );

      return responseEither.fold(
        (error) => Left(error),
        (response) {
          final List<dynamic> dataList = response.data['data'];
          final List<PaymentModel> payments = dataList
              .map((json) => PaymentModel.fromJson(json as Map<String, dynamic>))
              .toList();

          final meta = response.data['meta'];
          final int lastPage = meta != null ? meta['last_page'] as int : 1;

          return Right({
            'payments': payments,
            'lastPage': lastPage,
          });
        },
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> approvePayment(int paymentId) async {
    try {
      final responseEither = await DioHelper.postData(
        url: '$adminPaymentsApi/$paymentId/approve',
        data: {},
      );
      return responseEither.fold(
        (error) => Left(error),
        (response) => Right(response.data['message'] ?? 'Payment approved successfully'),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> rejectPayment(int paymentId) async {
    try {
      final responseEither = await DioHelper.postData(
        url: '$adminPaymentsApi/$paymentId/reject',
        data: {},
      );
      return responseEither.fold(
        (error) => Left(error),
        (response) => Right(response.data['message'] ?? 'Payment rejected successfully'),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }
}

