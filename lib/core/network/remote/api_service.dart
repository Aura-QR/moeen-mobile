// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:moean/main.dart';
// import 'package:moean/core/network/local/cache_helper.dart';
// import 'package:moean/core/utils/constants/routes.dart';
// import 'package:dio/dio.dart';
// import 'package:moean/core/network/remote/api_endpoints.dart';
// import 'package:moean/core/models/register_request.dart';
// import 'package:moean/core/models/register_response.dart';
// import 'package:moean/core/models/login_request.dart';
// import 'package:moean/core/models/login_response.dart';

// import 'package:moean/features/appointment/data/models/doctor_model.dart';
// import 'package:moean/features/appointment/data/models/appointment_model.dart';

// import 'package:moean/core/utils/constants/constants.dart';
// import 'package:moean/core/di/injections.dart';
// import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';

// class ApiService {
//   static final Dio _dio = Dio(
//     BaseOptions(
//       baseUrl: baseUrl,
//       connectTimeout: const Duration(seconds: 30),
//       receiveTimeout: const Duration(seconds: 30),
//       headers: {
//         'Accept': 'application/json',
//         'Content-Type': 'application/json',
        
//       },
//     ),
//   )..interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) {
//           try {
//             final isArabic = sl<ThemeCubit>().isArabicLang;
//             options.headers['Accept-Language'] = isArabic ? 'ar' : 'en';
//           } catch (_) {}
//           return handler.next(options);
//         },
//         onError: (DioException e, handler) async {
//           if (e.response?.statusCode == 401) {
//             try {
//               final context = navigatorKey.currentContext;
//               if (context != null) {
//                 await CacheHelper.removeData(key: 'auth_token');
//                 await CacheHelper.removeData(key: 'cached_user');
//                 setToken('');
//                 token = null;
//                 Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
//               }
//             } catch (_) {}
//           }
//           return handler.next(e);
//         },
//       ),
//     );

//   static void setToken(String token) {
//     _dio.options.headers['Authorization'] = 'Bearer $token';
//   }

//   static Future<RegisterResponse> registerUser(RegisterRequest request) async {
//     try {
//       final response = await _dio.post<Map<String, dynamic>>(
//         registerApi,
//         data: request.toJson(),
//       );
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return RegisterResponse.fromJson(response.data!);
//       } else {
//         return RegisterResponse(
//           success: false,
//           message:
//               response.data?['message']?.toString() ?? 'Registration failed',
//         );
//       }
//     } on DioException catch (e) {
//       String errorMessage = 'Registration failed';
//       if (e.response?.data != null && e.response?.data is Map) {
//         final data = e.response?.data as Map<String, dynamic>;
//         if (data['message'] != null) {
//           errorMessage = data['message'].toString();
//         } else if (data['errors'] != null && data['errors'] is Map) {
//           final errors = data['errors'] as Map<String, dynamic>;
//           errorMessage = errors.values
//               .map((e) => (e as List).join(', '))
//               .join('\n');
//         } else {
//           errorMessage = e.message ?? 'Registration failed';
//         }
//       } else {
//         errorMessage = e.message ?? 'Registration failed';
//       }
//       return RegisterResponse(success: false, message: errorMessage);
//     } catch (e) {
//       return RegisterResponse(success: false, message: e.toString());
//     }
//   }

//   static Future<LoginResponse> loginUser(LoginRequest request) async {
//     try {
//       final response = await _dio.post<Map<String, dynamic>>(
//         loginApi,
//         data: request.toJson(),
//       );
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return LoginResponse.fromJson(response.data!);
//       } else {
//         return LoginResponse(
//           success: false,
//           message: response.data?['message']?.toString() ?? 'Login failed',
//         );
//       }
//     } on DioException catch (e) {
//       String errorMessage = 'Login failed';
//       if (e.response?.data != null && e.response?.data is Map) {
//         final data = e.response?.data as Map<String, dynamic>;
//         if (data['error'] != null && data['error'] is Map && data['error']['detail'] != null) {
//           errorMessage = data['error']['detail'].toString();
//         } else {
//           errorMessage =
//               data['message']?.toString() ??
//               data['errors']?.toString() ??
//               e.message ??
//               'Login failed';
//         }
//       } else {
//         errorMessage = e.message ?? 'Login failed';
//       }
//       return LoginResponse(success: false, message: errorMessage);
//     } catch (e) {
//       return LoginResponse(success: false, message: e.toString());
//     }
//   }

//   static Future<PatientHomeModel> getPatientHomeData() async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(patientHomeApi);
//       return PatientHomeModel.fromJson(response.data!);
//     } catch (e) {
//       throw Exception('Failed to load home data: ${e.toString()}');
//     }
//   }

//   static Future<SpecialtiesResponse> getSpecialties() async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(specialtiesApi);
//       debugPrint('response.data ${response.data}');
//       return SpecialtiesResponse.fromJson(response.data!);
//     } catch (e) {
//       throw Exception('Failed to load specialties: ${e.toString()}');
//     }
//   }

//   static Future<CitiesResponse> getCities() async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(citiesApi);
//       return CitiesResponse.fromJson(response.data!);
//     } catch (e) {
//       throw Exception('Failed to load cities: ${e.toString()}');
//     }
//   }

//   static Future<GovernoratesResponse> getGovernorates() async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(governoratesApi);
//       return GovernoratesResponse.fromJson(response.data!);
//     } catch (e) {
//       throw Exception('Failed to load governorates: ${e.toString()}');
//     }
//   }

//   static Future<CitiesResponse> getCitiesByGovernorate(int governorateId) async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         citiesApi,
//         queryParameters: {'governorate_id': governorateId},
//       );
//       return CitiesResponse.fromJson(response.data!);
//     } catch (e) {
//       throw Exception('Failed to load cities by governorate: ${e.toString()}');
//     }
//   }

//   static Future<DoctorResponse> getDoctors({
//     int? cityId,
//     int? governorateId,
//     String? city,
//     int? specialtyId,
//     int? tenantId,
//     int? branchId,
//     int? facilityId,
//     String? search,
//   }) async {
//     debugPrint(
//       '[ApiService.getDoctors] governorateId=$governorateId, cityId=$cityId, city=$city, specialtyId=$specialtyId, tenantId=$tenantId, branchId=$branchId, facilityId=$facilityId, search=$search',
//     );
//     try {
//       final endpoint = doctorsApi;
//       debugPrint('[ApiService.getDoctors] endpoint=$endpoint');
//       final response = await _dio.get<Map<String, dynamic>>(
//         endpoint,
//         queryParameters: {
//           if (governorateId != null) 'governorate_id': governorateId,
//           if (cityId != null) 'city_id': cityId,
//           if (specialtyId != null) 'specialty_id': specialtyId,
//           if (branchId != null) 'branch_id': branchId,
//           if (tenantId != null) 'tenant_id': tenantId,
//           if (search != null && search.isNotEmpty) 'search': search,
//         },
//       );
//       debugPrint(
//         '[ApiService.getDoctors] status=${response.statusCode}, size=${(response.data?['data'] as List?)?.length ?? (response.data?['data']?['data'] as List?)?.length ?? 'unknown'}',
//       );
//       return DoctorResponse.fromJson(response.data!);
//     } on DioException {
//       rethrow;
//     } catch (e) {
//       throw Exception('Failed to load doctors: ${e.toString()}');
//     }
//   }

//   static Future<List<Map<String, dynamic>>> getBranches({String? branchType}) async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         branchesApi,
//         queryParameters: {
//           if (branchType != null) 'branch_type': branchType,
//         },
//       );
//       final List<dynamic> data = response.data?['data'] ?? [];
//       return List<Map<String, dynamic>>.from(data);
//     } catch (e) {
//       throw Exception('Failed to load branches: ${e.toString()}');
//     }
//   }

//   static Future<DoctorResponse> getNearbyDoctors({
//     required double lat,
//     required double lng,
//     int? specialtyId,
//     double radius = 50,
//   }) async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         nearbyDoctorsApi,
//         queryParameters: {
//           'lat': lat,
//           'lng': lng,
//           'specialty_id': specialtyId,
//           'radius': radius,
//         },
//       );
//       return DoctorResponse.fromJson(response.data!);
//     } on DioException {
//       rethrow;
//     } catch (e) {
//       throw Exception('Failed to load nearby doctors: ${e.toString()}');
//     }
//   }

//   static Future<List<FacilityModel>> getNearbyFacilities({
//     required double lat,
//     required double lng,
//     double radius = 10,
//     String? type,
//   }) async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         nearbyFacilitiesApi,
//         queryParameters: {
//           'latitude': lat,
//           'longitude': lng,
//           'radius': radius,
//           'type': type,
//         },
//       );
//       final List<dynamic> data = _extractDataList(response.data);
//       return data
//           .map((e) => FacilityModel.fromJson(e as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       throw Exception('Failed to load nearby facilities: ${_cleanErrorMessage(e)}');
//     }
//   }

//   static Future<List<AppointmentModel>> getAppointments({
//     String? status,
//     String? scope,
//     String? appointmentType,
//     int? doctorId,
//     int? branchId,
//     String? dateFrom,
//     String? dateTo,
//   }) async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         appointmentsApi,
//         queryParameters: {
//           'status': status,
//           'scope': scope,
//           'appointment_type': appointmentType,
//           'doctor_id': doctorId,
//           'branch_id': branchId,
//           'date_from': dateFrom,
//           'date_to': dateTo,
//         },
//       );
//       final List<dynamic> data = _extractDataList(response.data);
//       return data
//           .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       throw Exception('Failed to load appointments: ${e.toString()}');
//     }
//   }

//   static Future<AppointmentModel> bookAppointment(
//     AppointmentModel appointment,
//   ) async {
//     try {
//       final response = await _dio.post<Map<String, dynamic>>(
//         appointmentsApi,
//         data: appointment.toJson(),
//       );
//       return AppointmentModel.fromJson(response.data!['data']);
//     } catch (e) {
//       if (e is DioException && e.response?.data != null) {
//         throw Exception(
//           e.response?.data['message'] ?? 'Failed to book appointment',
//         );
//       }
//       throw Exception('Failed to book appointment: ${e.toString()}');
//     }
//   }

//   static Future<AppointmentModel> getAppointmentDetails(int id) async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         '$appointmentsApi/$id',
//       );
//       return AppointmentModel.fromJson(response.data!['data']);
//     } catch (e) {
//       throw Exception('Failed to load appointment details: ${e.toString()}');
//     }
//   }

//   static Future<List<String>> getAvailability({
//     required int doctorId,
//     required int branchId,
//     required String date,
//   }) async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         availabilityApi(doctorId, branchId),
//         queryParameters: {'date': date},
//       );
//       final List<dynamic> data = _extractDataList(response.data);
//       return data.map((e) => e.toString()).toList();
//     } catch (e) {
//       throw Exception('Failed to load availability: ${e.toString()}');
//     }
//   }

//   static Future<AppointmentModel> cancelAppointment(
//     int id, {
//     String? reason,
//   }) async {
//     try {
//       final response = await _dio.post<Map<String, dynamic>>(
//         cancelAppointmentApi.replaceFirst('{id}', id.toString()),
//         data: {'reason': reason},
//       );
//       return AppointmentModel.fromJson(response.data!['data']);
//     } catch (e) {
//       if (e is DioException && e.response?.data != null) {
//         throw Exception(
//           e.response?.data['message'] ?? 'Failed to cancel appointment',
//         );
//       }
//       throw Exception('Failed to cancel appointment: ${e.toString()}');
//     }
//   }

//   static Future<AppointmentModel> rescheduleAppointment(
//     int id,
//     String scheduledAt,
//   ) async {
//     try {
//       final response = await _dio.post<Map<String, dynamic>>(
//         rescheduleAppointmentApi.replaceFirst('{id}', id.toString()),
//         data: {'scheduled_at': scheduledAt},
//       );
//       return AppointmentModel.fromJson(response.data!['data']);
//     } catch (e) {
//       if (e is DioException && e.response?.data != null) {
//         throw Exception(
//           e.response?.data['message'] ?? 'Failed to reschedule appointment',
//         );
//       }
//       throw Exception('Failed to reschedule appointment: ${e.toString()}');
//     }
//   }

//   // Pharmacy Methods
//   static Future<List<MedicationModel>> searchMedications(String query) async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         medicationsApi,
//         queryParameters: {'search': query},
//       );
//       final List<dynamic> data = _extractDataList(response.data);
//       return data
//           .map((e) => MedicationModel.fromJson(e as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       throw Exception('Failed to search medications: ${e.toString()}');
//     }
//   }

//   static Future<List<PharmacyModel>> getNearbyPharmacies({
//     required double lat,
//     required double lng,
//     double? radius,
//     String? search,
//   }) async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         nearbyPharmaciesApi,
//         queryParameters: {
//           'lat': lat,
//           'lng': lng,
//           'radius': radius,
//           'search': search,
//         },
//       );
//       final List<dynamic> data = _extractDataList(response.data);
//       return data
//           .map((e) => PharmacyModel.fromJson(e as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       throw Exception('Failed to get nearby pharmacies: ${e.toString()}');
//     }
//   }

//   static Future<PharmacyModel> getPharmacyDetails(int id) async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         pharmacyDetailsApi(id),
//       );
//       final data = response.data?['data'] ?? response.data;
//       return PharmacyModel.fromJson(data as Map<String, dynamic>);
//     } catch (e) {
//       throw Exception('Failed to get pharmacy details: ${e.toString()}');
//     }
//   }

//   static Future<Map<String, dynamic>> createPharmacyRequest({
//     required String source,
//     required double lat,
//     required double lng,
//     double? radius,
//     List<MedicationCartItem>? items,
//     String? imagePath,
//     int? prescriptionId,
//     int? patientAddressId,
//   }) async {
//     try {
//       final requestRadius = radius ?? 100.0;

//       final Map<String, dynamic> commonParams = {
//         'source': source,
//         'lat': lat,
//         'lng': lng,
//         'latitude': lat,
//         'longitude': lng,
//         'radius': requestRadius,
//         'radius_km': requestRadius,
//         if (patientAddressId != null) 'patient_address_id': patientAddressId,
//       };

//       FormData? formData;
//       final Map<String, dynamic> data = Map.from(commonParams);

//       if (source == 'uploaded_image' && imagePath != null) {
//         data['image'] = await MultipartFile.fromFile(imagePath);
//         formData = FormData.fromMap(data);
//       } else if (source == 'manual_cart' && items != null) {
//         data['items'] = items.map((item) => item.toJson()).toList();
//       } else if (source == 'system' && prescriptionId != null) {
//         final url = systemPrescriptionPharmacyRequestsApi(prescriptionId);
//         debugPrint("Calling System Pharmacy Request API: $url");
//         final response = await _dio.post<Map<String, dynamic>>(
//           url,
//           queryParameters: commonParams,
//           data: {
//             ...commonParams,
//             'radius': requestRadius * 1000,
//           },
//         );
//         return response.data!;
//       }

//       final response = await _dio.post<Map<String, dynamic>>(
//         pharmacyRequestsApi,
//         queryParameters: commonParams,
//         data: formData ?? data,
//       );
//       return response.data!;
//     } on DioException catch (e) {
//       debugPrint("Dio Error: ${e.response?.statusCode}");
//       debugPrint("Dio Error Data: ${e.response?.data}");
//       throw Exception(
//         '${e.response?.data?['message'] ?? e.message}',
//       );
//     } catch (e) {
//       throw Exception('Failed to create pharmacy request: ${e.toString()}');
//     }
//   }

//   static Future<List<PharmacyRequestModel>> getPharmacyRequests() async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         pharmacyRequestsApi,
//       );
//       final List<dynamic> data = _extractDataList(response.data);
//       return data
//           .map((e) => PharmacyRequestModel.fromJson(e as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       throw Exception('Failed to load pharmacy requests: ${e.toString()}');
//     }
//   }

//   static Future<PharmacyRequestModel> getPharmacyRequestDetails(int id) async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         pharmacyRequestDetailsApi(id),
//       );
//       return PharmacyRequestModel.fromJson(response.data!['data']);
//     } catch (e) {
//       throw Exception(
//         'Failed to load pharmacy request details: ${e.toString()}',
//       );
//     }
//   }

//   static Future<Map<String, dynamic>> cancelPharmacyRequest(int id) async {
//     try {
//       debugPrint("Attempting to cancel pharmacy request #$id");
//       final response = await _dio.post<Map<String, dynamic>>(
//         cancelPharmacyRequestApi(id),
//       );
//       return response.data!;
//     } on DioException catch (e) {
//       debugPrint(
//         "Dio Error in cancelPharmacyRequest: ${e.response?.statusCode} - ${e.response?.data}",
//       );

//       if (e.response?.statusCode == 403) {
//         throw Exception(
//           "You don't have permission to cancel this request. It might be already accepted or processed by a pharmacy.",
//         );
//       }

//       throw Exception(
//         e.response?.data?['message'] ??
//             'Failed to cancel pharmacy request: ${e.message}',
//       );
//     } catch (e) {
//       throw Exception('Failed to cancel pharmacy request: ${e.toString()}');
//     }
//   }

//   static Future<Map<String, dynamic>> acceptPharmacyRequest(int id, String preference, String? address) async {
//     try {
//       final response = await _dio.post<Map<String, dynamic>>(
//         acceptPharmacyRequestApi(id),
//         data: {
//           'delivery_preference': preference,
//           'delivery_address': preference == 'delivery' ? address : null,
//         },
//       );
//       return response.data!;
//     } catch (e) {
//       if (e is DioException && e.response?.data != null) {
//         throw Exception(e.response?.data['message'] ?? 'Failed to accept request');
//       }
//       throw Exception('Failed to accept request: ${e.toString()}');
//     }
//   }

//   static Future<Map<String, dynamic>> rejectPharmacyRequest(int id) async {
//     try {
//       final response = await _dio.post<Map<String, dynamic>>(
//         rejectPharmacyRequestApi(id),
//       );
//       return response.data!;
//     } catch (e) {
//       if (e is DioException && e.response?.data != null) {
//         throw Exception(e.response?.data['message'] ?? 'Failed to reject request');
//       }
//       throw Exception('Failed to reject request: ${e.toString()}');
//     }
//   }

//   static Future<Map<String, dynamic>> approvePharmacyQuotation(int id, {int? addressId, String? address}) async {
//     try {
//       final response = await _dio.post<Map<String, dynamic>>(
//         approvePharmacyQuotationApi(id),
//         data: {
//           if (addressId != null) 'address_id': addressId,
//           if (address != null) 'address': address,
//           if (address != null) 'delivery_address': address,
//         },
//       );
//       return response.data!;
//     } catch (e) {
//       if (e is DioException && e.response?.data != null) {
//         throw Exception(
//           e.response?.data['message'] ?? 'Failed to approve quotation',
//         );
//       }
//       throw Exception('Failed to approve quotation: ${e.toString()}');
//     }
//   }

//   static Future<Map<String, dynamic>> rejectPharmacyQuotation(int id) async {
//     try {
//       final response = await _dio.post<Map<String, dynamic>>(
//         rejectPharmacyQuotationApi(id),
//       );
//       return response.data!;
//     } catch (e) {
//       if (e is DioException && e.response?.data != null) {
//         throw Exception(
//           e.response?.data['message'] ?? 'Failed to reject quotation',
//         );
//       }
//       throw Exception('Failed to reject quotation: ${e.toString()}');
//     }
//   }

//   // Medical Requests Methods
//   static Future<MedicalRequestsResponse> getMedicalRequestsWithMeta({
//     String? status,
//   }) async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         medicalRequestsApi,
//         queryParameters: {'status': status},
//         options: Options(headers: _authHeaders()),
//       );
//       return MedicalRequestsResponse.fromJson(response.data);
//     } catch (e) {
//       throw Exception('Failed to load medical requests: ${e.toString()}');
//     }
//   }

//   static Future<List<MedicalRequestModel>> getMedicalRequests({
//     String? status,
//   }) async {
//     final response = await getMedicalRequestsWithMeta(status: status);
//     return response.requests;
//   }

//   static Future<MedicalRequestModel> getMedicalRequestDetails(int id) async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         medicalRequestDetailsApi(id),
//         options: Options(headers: _authHeaders()),
//       );
//       final data = response.data!['data'] ?? response.data!;
//       return MedicalRequestModel.fromJson(data);
//     } catch (e) {
//       throw Exception('Failed to load medical request details: ${e.toString()}');
//     }
//   }

//   static Future<Map<String, dynamic>> cancelMedicalRequest(int id) async {
//     try {
//       final response = await _dio.post<Map<String, dynamic>>(
//         cancelMedicalRequestApi(id),
//         data: {},
//       );
//       return response.data!;
//     } on DioException catch (e) {
//       debugPrint(
//         "Dio Error in cancelMedicalRequest: ${e.response?.statusCode} - ${e.response?.data}",
//       );
//       throw Exception(
//         e.response?.data?['message'] ??
//             'Failed to cancel medical request: ${e.message}',
//       );
//     } catch (e) {
//       throw Exception('Failed to cancel medical request: ${e.toString()}');
//     }
//   }

//   static Future<List<FacilityModel>> getNearbyFacilitiesForRequest(
//     int requestId, {
//     double? lat,
//     double? lng,
//     double? radius,
//   }) async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         nearbyFacilitiesForRequestApi(requestId),
//         queryParameters: {
//           'latitude': lat,
//           'longitude': lng,
//           'radius': radius,
//         },
//       );
//       final List<dynamic> data = _extractDataList(response.data);
//       if (data.isNotEmpty) {
//         debugPrint("==== NEARBY FACILITIES RAW JSON ====");
//         debugPrint(data.first.toString());
//       } else {
//         debugPrint(
//           "==== NEARBY FACILITIES RETURNED EMPTY FOR REQUEST $requestId ====",
//         );
//       }
//       return data
//           .map((e) => FacilityModel.fromJson(e as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       throw Exception('Failed to find nearby facilities: ${e.toString()}');
//     }
//   }

//   static Future<Map<String, dynamic>> bookLabVisit(
//     int requestId, {
//     int? branchId,
//     String? scheduledAt,
//   }) async {
//     try {
//       final response = await _dio.post<Map<String, dynamic>>(
//         bookLabApi(requestId),
//         data: {
//           'branch_id': branchId,
//           'scheduled_at': scheduledAt,
//         },
//       );
//       debugPrint('===== LAB BOOKING RESPONSE START =====');
//       debugPrint(
//         'requestId: $requestId, branchId: $branchId, scheduledAt: $scheduledAt',
//       );
//       debugPrint(response.data.toString());
//       debugPrint('===== LAB BOOKING RESPONSE END =====');
//       return response.data!;
//     } catch (e) {
//       if (e is DioException && e.response?.data != null) {
//         throw Exception(e.response?.data['message'] ?? 'Failed to book lab');
//       }
//       throw Exception('Failed to book lab: ${e.toString()}');
//     }
//   }

//   static Future<Map<String, dynamic>> bulkBookLab({
//     required List<int> requestIds,
//     required int branchId,
//     String? scheduledDate,
//   }) async {
//     try {
//       final response = await _dio.post<Map<String, dynamic>>(
//         bulkBookLabApi,
//         data: {
//           'medical_request_ids': requestIds,
//           'branch_id': branchId,
//           'scheduled_date': scheduledDate,
//         },
//       );
//       debugPrint('===== BULK LAB BOOKING RESPONSE START =====');
//       debugPrint(
//         'requestIds: $requestIds, branchId: $branchId, scheduledDate: $scheduledDate',
//       );
//       debugPrint(response.data.toString());
//       debugPrint('===== BULK LAB BOOKING RESPONSE END =====');
//       return response.data!;
//     } catch (e) {
//       if (e is DioException && e.response?.data != null) {
//         throw Exception(e.response?.data['message'] ?? 'Failed to bulk book lab');
//       }
//       throw Exception('Failed to bulk book lab: ${e.toString()}');
//     }
//   }

//   static Future<List<dynamic>> getRadiologySlots(
//     int requestId,
//     int branchId,
//     String date,
//   ) async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         radiologySlotsApi(requestId),
//         queryParameters: {'branch_id': branchId, 'date': date},
//       );
//       debugPrint('===== RADIOLOGY SLOTS RESPONSE START (REQUEST) =====');
//       debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
//       debugPrint('===== RADIOLOGY SLOTS RESPONSE END (REQUEST) =====');
//       return response.data!['data'];
//     } catch (e) {
//       final radiologyError = _extractRadiologySlotsError(e);
//       if (radiologyError != null) {
//         throw Exception(radiologyError);
//       }
//       if (e is DioException && e.response?.data != null) {
//         debugPrint(
//           '===== RADIOLOGY SLOTS ERROR RESPONSE START (REQUEST) =====',
//         );
//         debugPrint(
//           const JsonEncoder.withIndent('  ').convert(e.response?.data),
//         );
//         debugPrint('===== RADIOLOGY SLOTS ERROR RESPONSE END (REQUEST) =====');
//       }
//       throw Exception('Failed to get radiology slots: ${_cleanErrorMessage(e)}');
//     }
//   }

//   static Future<Map<String, dynamic>> bookRadiologyVisit(
//     int requestId, {
//     required int branchId,
//     required String scheduledAt,
//     int? deviceId,
//   }) async {
//     try {
//       final response = await _dio.post<Map<String, dynamic>>(
//         bookRadiologyApi(requestId),
//         data: {
//           'branch_id': branchId,
//           'scheduled_at': scheduledAt,
//           // if (deviceId != null) 'device_id': deviceId,
//         },
//       );
//       debugPrint('===== RADIOLOGY BOOKING RESPONSE START =====');
//       debugPrint(
//         'requestId: $requestId, branchId: $branchId, scheduledAt: $scheduledAt',
//       );
//       debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
//       debugPrint('===== RADIOLOGY BOOKING RESPONSE END =====');
//       return response.data!;
//     } catch (e) {
//       if (e is DioException && e.response?.data != null) {
//         debugPrint('===== RADIOLOGY BOOKING ERROR RESPONSE START =====');
//         debugPrint(
//           const JsonEncoder.withIndent('  ').convert(e.response?.data),
//         );
//         debugPrint('===== RADIOLOGY BOOKING ERROR RESPONSE END =====');
//       }
//       throw Exception('Failed to book radiology: ${_cleanErrorMessage(e)}');
//     }
//   }

//   static Future<List<RadiologySlotModel>> getRadiologySlotsForRequest(
//     int requestId,
//     int branchId,
//     String dateStr, {
//     int? deviceId,
//   }) async {
//     try {
//       final queryParams = <String, dynamic>{
//         'branch_id': branchId,
//         'date': dateStr,
//       };
//       // if (deviceId != null) {
//       //   queryParams['device_id'] = deviceId;
//       // }
//       final response = await _dio.get<Map<String, dynamic>>(
//         radiologySlotsApi(requestId),
//         queryParameters: queryParams,
//       );
//       final List<dynamic> data = _extractDataList(response.data);
//       return data.map((e) => RadiologySlotModel.fromJson(e as Map<String, dynamic>)).toList();
//     } catch (e) {
//       final radiologyError = _extractRadiologySlotsError(e);
//       if (radiologyError != null) {
//         throw Exception(radiologyError);
//       }
//       throw Exception('Failed to get radiology slots: ${_cleanErrorMessage(e)}');
//     }
//   }

//   // Notifications Methods
//   static Future<List<NotificationModel>> getNotifications() async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(notificationsApi);
//       final List<dynamic> data = _extractDataList(response.data);
//       return data
//           .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       throw Exception('Failed to load notifications: ${e.toString()}');
//     }
//   }

//   static Future<List<NotificationModel>> getNotificationsByFilter(String filter) async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         notificationsApi,
//         queryParameters: {'filter': filter},
//       );
//       final List<dynamic> data = _extractDataList(response.data);
//       return data
//           .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       throw Exception('Failed to load filtered notifications: ${e.toString()}');
//     }
//   }

//   static Future<Map<String, dynamic>> handleNotificationAction(
//     String id,
//     String action,
//   ) async {
//     try {
//       final response = await _dio.post<Map<String, dynamic>>(
//         actionNotificationApi(id, action),
//       );
//       return response.data!;
//     } catch (e) {
//       throw Exception('Failed to perform action: ${e.toString()}');
//     }
//   }

//   static Future<Map<String, dynamic>> markNotificationAsRead(String id) async {
//     try {
//       final response = await _dio.post<Map<String, dynamic>>(
//         markNotificationReadApi(id),
//       );
//       return response.data!;
//     } catch (e) {
//       throw Exception('Failed to mark notification as read: ${e.toString()}');
//     }
//   }

//   static Future<void> markAllNotificationsAsRead() async {
//     try {
//       await _dio.post<Map<String, dynamic>>(
//         markAllNotificationsReadApi,
//       );
//     } catch (e) {
//       throw Exception(
//         'Failed to mark all notifications as read: ${e.toString()}',
//       );
//     }
//   }

//   static Future<void> updateFcmToken(String fcmToken) async {
//     try {
//       await _dio.post<dynamic>(
//         updateTokenApi,
//         data: {'fcm_token': fcmToken},
//       );
//     } catch (e) {
//       debugPrint("Error updating FCM token: $e");
//     }
//   }

//   // Access Requests
//   static Future<List<dynamic>> getAccessRequests() async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(accessRequestsApi);
//       return _extractDataList(response.data);
//     } catch (e) {
//       throw Exception('Failed to load access requests: ${e.toString()}');
//     }
//   }

//   static Future<Map<String, dynamic>> getAccessRequestDetail(int id) async {
//     final url = '$accessRequestsApi/$id';
//     debugPrint('🌐 API: Requesting GET $url');
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(url);
//       final data = response.data;
//       debugPrint('📥 API: Received response for ID: $id');
//       debugPrint('   Data: ${jsonEncode(data)}');
      
//       if (data != null && data['data'] is Map<String, dynamic>) {
//         return data['data'] as Map<String, dynamic>;
//       }
//       return data ?? {};
//     } catch (e) {
//       debugPrint('⚠️ API Error: $e');
//       throw Exception('Failed to load access request detail: ${e.toString()}');
//     }
//   }

//   static Future<void> approveAccessRequest(int id, String otp) async {
//     final url = approveAccessRequestApi(id);
//     final body = {'otp': otp, 'access_request_id': id};
//     debugPrint('📤 API: Approving request $id with body: $body');
//     try {
//       await _dio.post<dynamic>(url, data: body);
//     } on DioException catch (e) {
//       _handleDioError(e, 'Approve Access Request');
//     } catch (e) {
//       throw Exception('Failed to approve access request: ${e.toString()}');
//     }
//   }

//   static Future<void> rejectAccessRequest(int id) async {
//     final url = rejectAccessRequestApi(id);
//     debugPrint('📤 API: Rejecting request $id');
//     try {
//       await _dio.post<dynamic>(url);
//     } on DioException catch (e) {
//       _handleDioError(e, 'Reject Access Request');
//     } catch (e) {
//       throw Exception('Failed to reject access request: ${e.toString()}');
//     }
//   }

//   static Future<void> deleteAccessRequest(int id) async {
//     final url = '$accessRequestsApi/$id';
//     debugPrint('📤 API: Deleting request $id');
//     try {
//       await _dio.delete<dynamic>(url);
//     } on DioException catch (e) {
//       _handleDioError(e, 'Delete Access Request');
//     } catch (e) {
//       throw Exception('Failed to delete access request: ${e.toString()}');
//     }
//   }

//   static Future<void> resendAccessRequestOtp(int id) async {
//     final url = resendAccessRequestOtpApi(id);
//     debugPrint('📤 API: Resending OTP for request $id');
//     try {
//       await _dio.post<dynamic>(url);
//     } on DioException catch (e) {
//       _handleDioError(e, 'Resend OTP');
//     } catch (e) {
//       throw Exception('Failed to resend OTP: ${e.toString()}');
//     }
//   }

//   static void _handleDioError(DioException e, String action) {
//     debugPrint('⚠️ $action Error: ${e.response?.statusCode}');
//     debugPrint('   Response Body: ${jsonEncode(e.response?.data)}');
    
//     String message = e.message ?? 'Unknown error';
//     if (e.response?.data != null && e.response?.data is Map) {
//       final data = e.response!.data as Map<String, dynamic>;
//       message = data['message']?.toString() ?? data['error']?.toString() ?? message;
//       if (data['errors'] != null) {
//         message += ': ${data['errors'].toString()}';
//       }
//     }
//     throw Exception('$action: $message');
//   }

//   // Geo / Location
//   static Future<Map<String, dynamic>> updateLocation({
//     required double lat,
//     required double lng,
//   }) async {
//     try {
//       final response = await _dio.post<Map<String, dynamic>>(
//         updateLocationApi,
//         data: {'lat': lat, 'lng': lng},
//       );
//       return response.data!;
//     } catch (e) {
//       throw Exception('Failed to update location: ${e.toString()}');
//     }
//   }

//   static Future<Map<String, dynamic>> reverseGeocode({
//     required double lat,
//     required double lng,
//   }) async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         '/api/v1/patient/geo/reverse-geocode',
//         queryParameters: {'lat': lat, 'lng': lng},
//       );
//       return response.data!;
//     } catch (e) {
//       throw Exception('Failed to reverse geocode: ${e.toString()}');
//     }
//   }

//   // Pharmacy Quotations
//   static Future<List<dynamic>> getPrescriptionQuotations(
//     int prescriptionId,
//   ) async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         prescriptionQuotationsApi(prescriptionId),
//       );
//       return _extractDataList(response.data);
//     } catch (e) {
//       throw Exception('Failed to load quotations: ${e.toString()}');
//     }
//   }

//   // Global Search
//   static Future<List<GlobalMedicalService>> globalSearch(String query) async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         globalSearchApi,
//         queryParameters: {'q': query},
//       );
//       final List<dynamic> data = _extractDataList(response.data);
//       return data
//           .map((e) => GlobalMedicalService.fromJson(e as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       throw Exception('Global search failed: ${e.toString()}');
//     }
//   }

//   static Future<Map<String, dynamic>> globalSearchDynamic(
//     String query, {
//     String? type,
//   }) async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         globalSearchApi,
//         queryParameters: {
//           'q': query,
//           'type': type,
//         },
//       );
      
//       final data = response.data ?? <String, dynamic>{};
      
//       if (data['data'] is Map<String, dynamic>) {
//         return data['data'] as Map<String, dynamic>;
//       }
      
//       return data;
//     } catch (e) {
//       throw Exception('Global dynamic search failed: ${e.toString()}');
//     }
//   }

//   // Lab and Radiology specific requests
//   static Future<List<MedicalRequestModel>> getLabRequests({
//     String? status,
//   }) async {
//     try {
//       final response = await getMedicalRequestsWithMeta(status: status);
//       return response.requests.where((request) {
//         final requestType = request.serviceType.toLowerCase();
//         return requestType == 'lab_test' || requestType == 'lab';
//       }).toList();
//     } catch (e) {
//       throw Exception('Failed to load lab requests: ${e.toString()}');
//     }
//   }

//   static Future<List<MedicalRequestModel>> getRadiologyRequests({
//     String? status,
//   }) async {
//     try {
//       final response = await getMedicalRequestsWithMeta(status: status);
//       return response.requests.where((request) {
//         final requestType = request.serviceType.toLowerCase();
//         return requestType == 'radiology_scan' ||
//             requestType == 'radiology' ||
//             requestType == 'radiology_visit';
//       }).toList();
//     } catch (e) {
//       throw Exception('Failed to load radiology requests: ${e.toString()}');
//     }
//   }

//   // Diagnostic Facilities (Comparison and Listing)
//   static Future<List<FacilityModel>> getDiagnosticFacilities({
//     required double lat,
//     required double lng,
//     double radius = 10,
//     String? facilityType,
//     List<int>? serviceIds,
//     int? globalMedicalServiceId,
//     String? search,
//     String? sortBy,
//   }) async {
//     final resolvedServiceId =
//         globalMedicalServiceId ??
//         ((serviceIds != null && serviceIds.isNotEmpty)
//             ? serviceIds.first
//             : null);

//     final queryParameters = {
//       'latitude': lat,
//       'longitude': lng,
//       'radius_km': radius,
//       'facility_type': facilityType,
//       if (serviceIds != null && serviceIds.isNotEmpty)
//         'service_ids': serviceIds,
//       'global_medical_service_id': resolvedServiceId,
//       'service_id': resolvedServiceId,
//       'search': search,
//       'sort_by': sortBy,
//     };

//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         diagnosticFacilitiesApi,
//         queryParameters: queryParameters,
//       );
//       debugPrint(
//         "============= RAW DIAGNOSTIC FACILITIES API RESPONSE =============",
//       );
//       final rawDataStr = response.data.toString();
//       debugPrint("Data: $rawDataStr");

//       final List<dynamic> data = _extractDataList(response.data);
//       if (data.isNotEmpty) {
//         debugPrint("First Facility Raw JSON: \n${data.first}");
//         debugPrint(
//           "Does it have services? -> ${data.first.containsKey('services')}",
//         );
//         debugPrint("Keys inside first facility: ${data.first.keys.toList()}");

//         int i = 0;
//         for (var item in data) {
//           if (i > 2) break;
//           debugPrint(
//             "Facility ${item['branch_id'] ?? item['id']}: name=${item['name']}",
//           );
//           debugPrint(
//             "Services field: ${item['services'] ?? item['tests'] ?? item['available_tests'] ?? item['scans']}",
//           );
//           i++;
//         }
//       }
//       debugPrint(
//         "================================================================",
//       );

//       return data
//           .map((e) => FacilityModel.fromJson(e as Map<String, dynamic>))
//           .toList();
//     } on DioException catch (e) {
//       debugPrint('===== DIAGNOSTIC FACILITIES ERROR =====');
//       debugPrint('status: ${e.response?.statusCode}');
//       debugPrint('query: $queryParameters');
//       debugPrint('response: ${e.response?.data}');
//       debugPrint('message: ${e.message}');
//       debugPrint('======================================');

//       final backendMessage = e.response?.data is Map<String, dynamic>
//           ? ((e.response?.data as Map<String, dynamic>)['message']?.toString())
//           : null;

//       throw Exception(
//         'Failed to load diagnostic facilities: '
//         '${backendMessage ?? e.response?.data ?? e.message}',
//       );
//     } catch (e) {
//       throw Exception('Failed to load diagnostic facilities: ${_cleanErrorMessage(e)}');
//     }
//   }

//   static Future<List<dynamic>> compareServices({
//     required List<int> serviceIds,
//     required double lat,
//     required double lng,
//     double radius = 10.0,
//   }) async {
//     try {
//       final response = await _dio.post<Map<String, dynamic>>(
//         compareServicesApi,
//         data: {
//           'service_ids': serviceIds,
//           'latitude': lat,
//           'longitude': lng,
//           'radius_km': radius,
//         },
//       );
//       return _extractDataList(response.data);
//     } catch (e) {
//       throw Exception('Failed to compare services: ${_cleanErrorMessage(e)}');
//     }
//   }

//   static Future<Map<String, dynamic>> directBookDiagnostic({
//     required int branchId,
//     required List<int> serviceIds,
//     String? scheduledAt,
//     int? deviceId,
//   }) async {
//     try {
//       final response = await _dio.post<Map<String, dynamic>>(
//         directBookApi,
//         data: {
//           'branch_id': branchId,
//           'service_ids': serviceIds,
//           'scheduled_at': scheduledAt,
//           if (deviceId != null) 'device_id': deviceId,
//         },
//       );
//       debugPrint('===== DIRECT DIAGNOSTIC BOOKING RESPONSE START =====');
//       debugPrint(
//         'branchId: $branchId, serviceIds: $serviceIds, scheduledAt: $scheduledAt, deviceId: $deviceId',
//       );
//       debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
//       debugPrint('===== DIRECT DIAGNOSTIC BOOKING RESPONSE END =====');
//       return response.data!;
//     } catch (e) {
//       if (e is DioException && e.response?.data != null) {
//         debugPrint(
//           '===== DIRECT DIAGNOSTIC BOOKING ERROR RESPONSE START =====',
//         );
//         debugPrint(
//           const JsonEncoder.withIndent('  ').convert(e.response?.data),
//         );
//         debugPrint('===== DIRECT DIAGNOSTIC BOOKING ERROR RESPONSE END =====');
//         throw Exception(e.response?.data['message'] ?? 'Direct booking failed');
//       }
//       throw Exception('Direct booking failed: ${_cleanErrorMessage(e)}');
//     }
//   }

//   static Future<List<DiagnosticServiceModel>> getFacilityServices(
//     int branchId,
//   ) async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         '/api/v1/patient/facilities/$branchId',
//       );

//       final Map<String, dynamic> data = response.data?['data'] ?? {};
//       final List<dynamic> services =
//           data['services'] ??
//           data['available_tests'] ??
//           data['available_scans'] ??
//           data['tests'] ??
//           data['scans'] ??
//           [];

//       return services
//           .map(
//             (e) => DiagnosticServiceModel.fromJson(e as Map<String, dynamic>),
//           )
//           .toList();
//     } catch (e) {
//       debugPrint(
//         "Error loading services for branch $branchId: ${e.toString()}",
//       );
//       throw Exception('Failed to load facility services: ${_cleanErrorMessage(e)}');
//     }
//   }

//   static Future<List<RadiologyDeviceModel>> getFacilityDevices(
//     int branchId,
//   ) async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         '/api/v1/radiology/devices',
//         queryParameters: {'branch_id': branchId},
//       );

//       final List<dynamic> data = _extractDataList(response.data);
//       return data
//           .map(
//             (e) => RadiologyDeviceModel.fromJson(e as Map<String, dynamic>),
//           )
//           .toList();
//     } catch (e) {
//       throw Exception('Failed to load radiology devices: ${_cleanErrorMessage(e)}');
//     }
//   }

//   static Future<List<RadiologySlotModel>> getDirectRadiologySlots(
//     int branchId,
//     String date, {
//     int? deviceId,
//     int? serviceId,
//   }) async {
//     try {
//       final queryParams = <String, dynamic>{
//         'date': date.toString(),
//         'device_id': deviceId,
//         'service_id': serviceId,
//       };
//       queryParams.removeWhere((key, value) => value == null);

//       final response = await _dio.get<Map<String, dynamic>>(
//         '/api/v1/patient/facilities/$branchId/radiology-slots',
//         queryParameters: queryParams,
//         options: Options(
//           headers: {'Accept': 'application/json'},
//         ),
//       );

//       debugPrint('===== DIRECT RADIOLOGY SLOTS RESPONSE START =====');
//       debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
//       debugPrint('===== DIRECT RADIOLOGY SLOTS RESPONSE END =====');

//       final List<dynamic> data = response.data?['data'] ?? [];
//       return data.map((e) => RadiologySlotModel.fromJson(e as Map<String, dynamic>)).toList();
//     } catch (e) {
//       final radiologyError = _extractRadiologySlotsError(e);
//       if (radiologyError != null) {
//         throw Exception(radiologyError);
//       }
//       if (e is DioException && e.response?.data != null) {
//         debugPrint('===== DIRECT RADIOLOGY SLOTS ERROR RESPONSE START =====');
//         debugPrint(
//           const JsonEncoder.withIndent('  ').convert(e.response?.data),
//         );
//         debugPrint('===== DIRECT RADIOLOGY SLOTS ERROR RESPONSE END =====');
//       }
//       throw Exception('Failed to load radiology slots: ${_cleanErrorMessage(e)}');
//     }
//   }

//   static List<dynamic> _extractDataList(Map<String, dynamic>? data) {
//     if (data == null || data['data'] == null) return [];
//     final rawData = data['data'];
//     if (rawData is List) return rawData;
//     if (rawData is Map && rawData['data'] is List) return rawData['data'];
//     return [];
//   }

//   static Map<String, dynamic> _authHeaders() {
//     final authHeader = _dio.options.headers['Authorization'];
//     if (authHeader is String && authHeader.isNotEmpty) {
//       return <String, dynamic>{};
//     }

//     if (token != null && token!.isNotEmpty) {
//       return {'Authorization': 'Bearer $token'};
//     }

//     return <String, dynamic>{};
//   }

//   static Future<List<MedicalDocument>> getMedicalRecordDocuments() async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         medicalRecordDocumentsApi,
//       );
//       final List<dynamic> data = _extractDataList(response.data);
//       return data
//           .map((e) => MedicalDocument.fromJson(e as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       throw Exception('Failed to load documents: ${_cleanErrorMessage(e)}');
//     }
//   }

//   static Future<DocumentDetailsModel> getDocumentDetails(int documentId) async {
//     try {
//       final response = await _dio.get<Map<String, dynamic>>(
//         documentDetailsApi(documentId),
//       );
//       return DocumentDetailsModel.fromJson(response.data ?? {});
//     } catch (e) {
//       throw Exception(
//           'Failed to load document details: ${_cleanErrorMessage(e)}');
//     }
//   }

//   static String getDocumentDownloadUrl(int documentId) {
//     return '$baseUrl${downloadDocumentApi(documentId)}';
//   }

//   static String? _extractRadiologySlotsError(Object error) {
//     const unavailableMessage =
//         'No active radiology device is configured for this service at this branch';
//     if (error is DioException) {
//       final data = error.response?.data;
//       if (data is Map<String, dynamic>) {
//         final message = data['message']?.toString() ?? data['error']?.toString();
//         if (message != null && message.contains(unavailableMessage)) {
//           return 'radiology_service_unavailable';
//         }
//       }
//       if ((error.message ?? '').contains(unavailableMessage)) {
//         return 'radiology_service_unavailable';
//       }
//     }

//     final raw = error.toString();
//     if (raw.contains(unavailableMessage)) {
//       return 'radiology_service_unavailable';
//     }

//     return null;
//   }

//   static String _cleanErrorMessage(Object error) {
//     if (error is DioException) {
//       if (error.response?.data != null && error.response?.data is Map) {
//         final data = error.response?.data as Map<String, dynamic>;
//         return data['message']?.toString() ??
//             data['error']?.toString() ??
//             error.message ??
//             'Unknown error';
//       }
//       return error.message ?? 'Unknown error';
//     }
//     return error.toString();
//   }
// }
