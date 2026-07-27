//const String baseUrl = 'http://192.168.1.13:8000/api';

const String baseUrl = 'https://librechat-assiut-moeen-backend.tfgpna.easypanel.host/api';

const String registerApi = '/auth/register';
const String loginApi = '/auth/login';
const String meApi = '/auth/me';
const String logoutApi = '/auth/logout';
const String changePasswordApi = '/auth/password';
const String connectMadrasatiApi = '/madrasati/connect';
const String refreshMadrasatiSessionApi = '/madrasati/refresh-session';
const String scheduleApi = '/schedule';
const String madrasatiScheduleApi = '/madrasati/schedule';
const String prepareApi = '/prepare';

// Admin API
const String adminTeachersApi = '/admin/teachers';
const String subscriptionsApi = '/subscriptions';
const String adminContactStatsApi = '/admin/contact/stats';
const String adminContactApi = '/admin/contact';
const String adminPaymentsApi = '/admin/payments';
const String adminPendingQuestionsApi = '/admin/questions/pending-review';
String adminReviewQuestionApi(int id) => '/admin/questions/$id/review';

// Contact API
const String contactTypesApi = '/contact/types';
const String contactApi = '/contact';
const String contactMyApi = '/contact/my';

// Reports API
const String educationalReportApi = '/reports/educational/generate';
const String savedEducationalReportsApi = '/reports/educational';

// Payment & Subscription API
const String subscriptionCurrentApi = '/subscription/current';
const String ordersApi = '/orders';
const String paymentsVerifyApi = '/payments/verify';
const String paymentsSaveReferenceApi = '/payments/save-reference';
const String paymentsManualApi = '/payments/manual';
const String paymentsBankTransferInfoApi = '/payments/bank-transfer-info';
const String paymentsHistoryApi = '/payments/history';

// Exam Generation API
const String examsGenerateApi = '/exams/generate';
const String examsApi = '/exams';
const String questionsApi = '/questions';
const String questionsMyApi = '/questions/my';
String questionUpdateApi(int id) => '/questions/$id';
String examDetailsApi(int id) => '/exams/$id';
String examPointsApi(int id) => '/exams/$id/questions/points';
String examPublishApi(int id) => '/exams/$id/publish';

// Search API
const String searchApi = '/search';

// Curriculum API
const String subjectsApi = '/subjects';
String subjectLessonsApi(int id) => '/subjects/$id/lessons';
String lessonQuestionsApi(int id) => '/lessons/$id/questions';
String lessonPresentationApi(int id) => '/lessons/$id/presentation';
String lessonPresentationGenerateApi(int id) => '/lessons/$id/presentation/generate';
