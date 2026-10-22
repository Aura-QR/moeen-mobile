//const String baseUrl = 'http://192.168.1.13:8000/api';

const String baseUrl = 'https://api.haderedu.com/api';

const String registerApi = '/auth/register';
const String loginApi = '/auth/login';
const String meApi = '/auth/me';
const String logoutApi = '/auth/logout';
const String changePasswordApi = '/auth/password';
const String forgotPasswordApi = '/auth/forgot-password';
const String resetPasswordApi = '/auth/reset-password';
const String resendEmailVerificationApi = '/auth/email/resend-verification';
const String verifyEmailApi = '/auth/email/verify';
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
const String paymentsMyfatoorahSessionApi = '/payments/myfatoorah/session';
const String paymentsMyfatoorahExecuteApi = '/payments/myfatoorah/execute';
const String paymentsMyfatoorahVerifyApi = '/payments/myfatoorah/verify';

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

// Referral & Promo API
const String referralsMeApi = '/referrals/me';
const String promoValidateApi = '/promo-codes/validate';

// Admin Promo & Referral API
const String adminPromoCodesApi = '/admin/promo-codes';
const String adminReferralStatsApi = '/admin/referrals/statistics';
String adminPromoActivateApi(int id) => '/admin/promo-codes/$id/activate';
String adminPromoDeactivateApi(int id) => '/admin/promo-codes/$id/deactivate';
String adminPromoDeleteApi(int id) => '/admin/promo-codes/$id';

// Curriculum Distribution & Books API
const String curriculumPlansApi = '/curriculum/plans';
String curriculumPlanDetailApi(int id) => '/curriculum/plans/$id';
String curriculumPlanCurrentWeekApi(int id) => '/curriculum/plans/$id/weeks/current';
const String curriculumBooksApi = '/curriculum/books';
String curriculumBookDownloadApi(int id) => '/curriculum/books/$id/download';
const String curriculumProgressApi = '/curriculum/progress';
String curriculumPlanWeekPrepareApi(int planId, int weekId) =>
    '/curriculum/plans/$planId/weeks/$weekId/prepare';


// Portfolio API
const String portfolioRolesApi = '/portfolios/roles';
const String portfoliosApi = '/portfolios';
String portfolioApi(int id) => '/portfolios/$id';
String portfolioShareApi(int id) => '/portfolios/$id/share';
String portfolioItemsApi(int id) => '/portfolios/$id/items';
String portfolioItemApi(int id, int itemId) => '/portfolios/$id/items/$itemId';
String portfolioItemUploadsApi(int id, int itemId) =>
    '/portfolios/$id/items/$itemId/uploads';
String portfolioItemFilesApi(int id, int itemId) =>
    '/portfolios/$id/items/$itemId/files';
String portfolioItemFilesOrderApi(int id, int itemId) =>
    '/portfolios/$id/items/$itemId/files/order';
String portfolioItemFileApi(int id, int itemId, int fileId) =>
    '/portfolios/$id/items/$itemId/files/$fileId';
String portfolioItemDocumentsApi(int id, int itemId) =>
    '/portfolios/$id/items/$itemId/documents';

// Teacher Documents API (DOCUMENTS_API.md)
const String documentDefaultsApi = '/me/document-defaults';
const String documentsApi = '/documents';
const String documentUploadsApi = '/documents/uploads';
// Renders the form as it is now, without saving (§ 4.3)
const String documentPreviewApi = '/documents/preview';
String documentApi(int id) => '/documents/$id';
String documentDuplicateApi(int id) => '/documents/$id/duplicate';
String documentPrintApi(int id) => '/documents/$id/print';
String documentExportsApi(int id) => '/documents/$id/exports';
String documentExportApi(int id, int exportId) => '/documents/$id/exports/$exportId';

// Tool catalogues
const String strategiesApi = '/tools/strategies';
String strategyApi(String key) => '/tools/strategies/$key';
const String remedialToolApi = '/tools/remedial';
const String enrichmentToolApi = '/tools/enrichment';
const String activitiesToolApi = '/tools/activities';
const String activitiesPlanApi = '/tools/activities/plan';
const String certificatesToolApi = '/tools/certificates';

// T7 «تحليل نتائج الطلاب» (GRADE_ANALYSIS_API.md)
const String gradesToolApi = '/tools/grades';
const String gradesAnalyzeApi = '/tools/grades/analyze';
const String gradesImportApi = '/tools/grades/import';
const String gradesDataApi = '/tools/grades/data';

// «فصولي» saved classes (CLASSES_API.md)
const String classesApi = '/classes';
const String classesImportApi = '/classes/import';
String classApi(int id) => '/classes/$id';
// «استيراد من مدرستي»: classes and names read from Madrasati with the connected account
const String madrasatiClassesApi = '/classes/madrasati';
String madrasatiClassApi(String madrasatiId) => '/classes/madrasati/${Uri.encodeComponent(madrasatiId)}';

// AI suggestions for the document tools (AI_JOBS_API.md)
const String aiJobsApi = '/ai-jobs';
String aiJobApi(int id) => '/ai-jobs/$id';

// Achievement Report API
const String achievementReportApi = '/reports/achievements';
