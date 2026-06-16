const String baseUrl = 'https://v2-api.qraura.shop';

const String loginApi = '/api/v1/auth/login';
const String registerApi = '/api/v1/auth/register';
const String sendOtpApi = '/api/v1/auth/phone/send-otp';
const String resendOtpApi = '/api/v1/auth/phone/resend-otp';
const String verifyOtpApi = '/api/v1/auth/phone/verify-otp';
const String forgotPasswordApi = '/api/v1/auth/forgot-password';
const String resetPasswordApi = '/api/v1/auth/reset-password';
const String changePasswordApi = '/api/v1/auth/change-password';
const String logoutApi = '/api/v1/auth/logout';
const String logoutAllApi = '/api/v1/auth/logout-all';
const String bootstrapApi = '/api/v1/app/bootstrap';

const String pendingApprovals = '/pending-approvals';

const String allLogs = '/audit/all-logs';

const String transfers = '/asset-transfers/pending';

const String retirements = '/retirements/pending';

const String tickets = '/tickets';

const String approveTransfers = '/asset-transfers/batch/action';

const String patientProfileApi = '/api/v1/patient/profile';
const String deleteAccountOtpApi = '/api/v1/patient/account/deletion-otp';
const String deleteAccountApi = '/api/v1/patient/account/delete';
const String meApi = '/api/v1/me';
const String medicalRecordsApi = '/api/v1/patient/medical-record';
const String medicalRecordDocumentsApi =
    '/api/v1/patient/medical-record/documents';

String doctorMedicalRecordApi(int patientId) =>
    '/api/v1/patients/$patientId/medical-record';
const String patientHomeApi = '/api/v1/patient/home';
const String specialtiesApi = '/api/v1/specialties';
const String doctorsApi = '/api/v1/doctors';
const String governoratesApi = '/api/v1/governorates';
const String citiesApi = '/api/v1/cities';
const String branchesApi = '/api/v1/branches';
const String nearbyFacilitiesApi = '/api/v1/patient/geo/nearby';
const String nearbyDoctorsApi = '/api/v1/patient/geo/nearby-doctors';
const String updateLocationApi = '/api/v1/patient/geo/update-location';
const String globalSearchApi = '/api/v1/global-search';

const String appointmentsApi = '/api/v1/patient/appointments';
const String cancelAppointmentApi = '/api/v1/patient/appointments/{id}/cancel';
const String rescheduleAppointmentApi =
    '/api/v1/patient/appointments/{id}/reschedule';

// Pharmacy Endpoints
const String pharmacyRequestsApi = '/api/v1/patient/pharmacy-requests';
String systemPrescriptionPharmacyRequestsApi(int id) =>
    '/api/v1/patient/prescriptions/$id/pharmacy-requests';
const String nearbyPharmaciesApi = '/api/v1/patient/geo/nearby-pharmacies';
String pharmacyDetailsApi(int id) => '/api/v1/patient/geo/facilities/$id';
const String medicationsApi = '/api/v1/medications';
String prescriptionQuotationsApi(int id) =>
    '/api/v1/patient/prescriptions/$id/quotations';
String pharmacyRequestDetailsApi(int id) =>
    '/api/v1/patient/pharmacy-requests/$id';
String cancelPharmacyRequestApi(int id) =>
    '/api/v1/patient/pharmacy-requests/$id/cancel';
String approvePharmacyQuotationApi(int id) =>
    '/api/v1/patient/pharmacy-requests/$id/approve';
String rejectPharmacyQuotationApi(int id) =>
    '/api/v1/patient/pharmacy-requests/$id/reject';
String acceptPharmacyRequestApi(int id) =>
    '/api/v1/patient/pharmacy-requests/$id/accept';
String rejectPharmacyRequestApi(int id) =>
    '/api/v1/patient/pharmacy-requests/$id/reject';

// Medical Requests Endpoints
const String medicalRequestsApi = '/api/v1/patient/medical-requests';
String medicalRequestDetailsApi(int id) => '/api/v1/patient/medical-requests/$id';
String nearbyFacilitiesForRequestApi(int id) =>
    '/api/v1/patient/medical-requests/$id/nearby-facilities';
String bookLabApi(int id) => '/api/v1/patient/medical-requests/$id/book-lab';
const String bulkBookLabApi = '/api/v1/patient/medical-requests/bulk-book-lab';
String radiologySlotsApi(int id) =>
    '/api/v1/patient/medical-requests/$id/radiology-slots';
String bookRadiologyApi(int id) =>
    '/api/v1/patient/medical-requests/$id/book-radiology';
String cancelMedicalRequestApi(int id) =>
    '/api/v1/patient/medical-requests/$id/cancel';
const String labRequestsApi = '/api/v1/patient/lab-requests';
const String radiologyRequestsApi = '/api/v1/patient/radiology-requests';
const String diagnosticFacilitiesApi = '/api/v1/patient/facilities/diagnostics';
const String compareServicesApi = '/api/v1/patient/services/compare';
const String directBookApi = '/api/v1/patient/appointments/direct-book';

// Notifications
const String notificationsApi = '/api/v1/notifications';
const String markAllNotificationsReadApi = '/api/v1/notifications/read-all';
String markNotificationReadApi(String id) => '/api/v1/notifications/$id/read';
String actionNotificationApi(String id, String action) =>
    '/api/v1/notifications/$id/$action';
const String updateTokenApi = '/api/v1/notifications/update-token';

const String prescriptionsApi = '/api/v1/patient/prescriptions';
String prescriptionDetailsApi(int id) => '/api/v1/patient/prescriptions/$id';
const String consultationsApi = '/api/v1/patient/consultations';
String consultationDetailsApi(int id) => '/api/v1/patient/consultations/$id';
const String addPatientHistoryApi = '/api/v1/patient/histories';
const String patientHistoriesApi = '/api/v1/patient/histories';
String deletePatientHistoryApi(int id) => '/api/v1/patient/histories/$id';
const String accessRequestsApi = '/api/v1/patient/access-requests';
String approveAccessRequestApi(int id) =>
    '/api/v1/patient/access-requests/$id/approve';
String rejectAccessRequestApi(int id) =>
    '/api/v1/patient/access-requests/$id/reject';
String resendAccessRequestOtpApi(int id) =>
    '/api/v1/patient/access-requests/$id/resend-otp';
String deleteAccessRequestOtpApi(int id) =>
    '/api/v1/patient/access-requests/$id/delete-otp';

String availabilityApi(int doctorId, int branchId) =>
    '/api/v1/patient/doctors/$doctorId/branches/$branchId/availability';

String downloadDocumentApi(int id) => '/api/v1/documents/$id/download';
String documentDetailsApi(int id) => '/api/v1/patient/documents/$id';

// Specialty Summary
String specialtySummaryApi(int specialtyId) =>
    '/api/v1/patient/specialties/$specialtyId/summary';

// Saved Addresses
const String patientAddressesApi = '/api/v1/patient/addresses';
String patientAddressDetailsApi(int id) => '/api/v1/patient/addresses/$id';
String setDefaultAddressApi(int id) => '/api/v1/patient/addresses/$id/default';

// Chatbot Endpoints
const String chatbotConversationsApi = '/api/v1/chatbot/conversations';
String chatbotConversationDetailsApi(int id) => '/api/v1/chatbot/conversations/$id';
String chatbotMessagesApi(int id) => '/api/v1/chatbot/conversations/$id/messages';

