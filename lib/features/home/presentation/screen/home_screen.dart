import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/core/models/madrasati_session_data.dart';
import 'package:moean/core/network/local/secure_storage_helper.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:moean/core/utils/cubit/theme/theme_state.dart';
import 'package:moean/core/widgets/dot_grid_painter.dart';
import 'package:moean/core/widgets/session_expired_dialog.dart';
import 'package:moean/features/home/presentation/cubit/home_cubit.dart';
import 'package:moean/features/home/presentation/widgets/home_app_bar_widget.dart';
import 'package:moean/features/home/presentation/widgets/home_hero_banner_widget.dart';
import 'package:moean/features/home/presentation/widgets/home_tip_of_day_widget.dart';
import 'package:moean/features/home/presentation/widgets/home_features_section_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit()..checkRole(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return Scaffold(
            backgroundColor: ColorsManager.background,
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: Stack(
                children: [
                    Positioned(
                      right: 20,
                      top: 200,
                      height: 150,
                      width: 140,
                      child: CustomPaint(
                        painter: DotGridPainter(
                          color: ColorsManager.primaryColor.withValues(alpha: 0.15),
                          spacing: 16.0,
                        ),
                      ),
                    ),
                    SafeArea(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ignore: prefer_const_constructors
                              HomeAppBarWidget(),
                              verticalSpace24,
                              // ignore: prefer_const_constructors
                              HomeHeroBannerWidget(),
                              verticalSpace40,
                              const HomeFeaturesSectionWidget(),
                              verticalSpace40,
                              // ignore: prefer_const_constructors
                              HomeTipOfDayWidget(),
                              // ── DEBUG ONLY: Session Expiry Tester ──────────
                              // Visible ONLY in debug mode. Safe to leave in code.
                              if (kDebugMode) ...[                              
                                verticalSpace24,
                                _DebugSessionExpireButton(),
                                verticalSpace24,
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
      ),
    );
  }
}

/// DEBUG ONLY — directly calls /madrasati/refresh-session using saved credentials.
/// Only rendered when [kDebugMode] is true (never in production builds).
class _DebugSessionExpireButton extends StatefulWidget {
  @override
  State<_DebugSessionExpireButton> createState() =>
      _DebugSessionExpireButtonState();
}

class _DebugSessionExpireButtonState extends State<_DebugSessionExpireButton> {
  bool _loading = false;

  Future<void> _triggerRefresh() async {
    setState(() => _loading = true);

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🧪 [DEBUG] Manual refresh-session triggered from HomeScreen');

    // ── Step 1: قرأ الجلسة المحفوظة ─────────────────────────────────────
    final savedSession = await sl<SecureStorageHelper>().getMadrasatiSession();
    final refreshToken = savedSession?.refreshToken;
    final schoolId     = savedSession?.schoolId;

    debugPrint('📂 Saved credentials:');
    debugPrint('   schoolId     : ${schoolId ?? '❌ null'}');
    debugPrint('   refreshToken : ${refreshToken != null && refreshToken.isNotEmpty ? '✅ "${refreshToken.substring(0, refreshToken.length.clamp(0, 30))}…"' : '❌ null or empty'}');

    // ── Step 2: لو مفيش session محفوظة → دايلوج لازم تعمل connect ──────
    if (refreshToken == null || refreshToken.isEmpty ||
        schoolId == null || schoolId.isEmpty) {
      debugPrint('⚠️ [DEBUG] No local session — showing SessionExpiredDialog (must re-connect)');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      setState(() => _loading = false);
      if (mounted) SessionExpiredDialog.show(context);
      return;
    }

    // ── Step 3: في session → نادى /refresh-session ──────────────────────
    try {
      debugPrint('📡 [DEBUG] POST $refreshMadrasatiSessionApi');
      final response = await DioHelper.postData(
        url: refreshMadrasatiSessionApi,
        data: {
          'refresh_token': refreshToken,
          'madrasati_school_id': schoolId,
        },
      );

      response.fold(
        // ─── Left: خطأ من DioHelper ──────────────────────────────────
        (error) {
          debugPrint('💥 [DEBUG] Request failed (LEFT): $error');
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

          // نفرّق: خطأ شبكة (انقطاع) vs خطأ مصادقة (session منتهية)
          final errLow = error.toLowerCase();
          final isNetworkError = errLow.contains('socket') ||
              errLow.contains('connection') ||
              errLow.contains('timeout') ||
              errLow.contains('network') ||
              errLow.contains('unreachable') ||
              errLow.contains('reset');

          if (isNetworkError) {
            // ✋ انقطع الإنترنت — مش نبوّع الدايلوج
            debugPrint('📵 [DEBUG] Network error detected — NOT showing dialog');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📵 تحقق من اتصال الإنترنت وحاول مجدداً'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 4),
                ),
              );
            }
          } else {
            // ❌ خطأ مصادقة — لازم يعمل connect من أول
            debugPrint('🔐 [DEBUG] Auth error — showing SessionExpiredDialog');
            if (mounted) SessionExpiredDialog.show(context);
          }
        },

        // ─── Right: جه رد من الباك ────────────────────────────────────
        (res) async {
          debugPrint('');
          debugPrint('┌─────────────────────────────────────────────────────────┐');
          debugPrint('│   📦 /refresh-session RESPONSE — Full Breakdown          │');
          debugPrint('├─────────────────────────────────────────────────────────┤');
          debugPrint('│ HTTP statusCode : ${res.statusCode}');
          debugPrint('├─────────────────────────────────────────────────────────┤');
          debugPrint('│ [top-level]');
          debugPrint('│   success  : ${res.data['success']}');
          debugPrint('│   message  : ${res.data['message']}');
          debugPrint('├─────────────────────────────────────────────────────────┤');
          debugPrint('│ [data] object:');

          final dataObj = res.data['data'];
          if (dataObj == null) {
            debugPrint('│   ⚠️  data is NULL — backend returned no data object');
          } else {
            final d = dataObj as Map;
            final cookie = d['session_cookie'] as String?;
            debugPrint('│   session_cookie    : ${cookie != null ? '✅ "${cookie.substring(0, cookie.length.clamp(0, 30))}…"' : '❌ null'}');
            final newRT = d['new_refresh_token'] as String?;
            debugPrint('│   new_refresh_token : ${newRT != null ? '✅ "${newRT.substring(0, newRT.length.clamp(0, 30))}…"' : '❌ null — old token reused'}');
            final rt = d['refresh_token'] as String?;
            debugPrint('│   refresh_token     : ${rt != null ? '✅ "${rt.substring(0, rt.length.clamp(0, 30))}…"' : '❌ null'}');
            final exp = d['expires_at'];
            debugPrint('│   expires_at        : ${exp ?? '❌ null'}');
            final known = {'session_cookie', 'new_refresh_token', 'refresh_token', 'expires_at'};
            final extras = d.keys.where((k) => !known.contains(k)).toList();
            if (extras.isNotEmpty) debugPrint('│   [extra fields] : $extras');
          }
          debugPrint('└─────────────────────────────────────────────────────────┘');
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

          final success = res.data['success'] == true;
          final message = res.data['message'] as String? ?? '';

          if (success) {
            // ✅ نجحت — نحفظ الجلسة الجديدة
            final d = res.data['data'] as Map<String, dynamic>?;
            if (d != null) {
              final newCookie  = d['session_cookie']    as String?;
              final newRT      = (d['new_refresh_token'] ?? d['refresh_token']) as String?;
              final expiresRaw = d['expires_at']         as String?;
              final expiry     = expiresRaw != null
                  ? DateTime.tryParse(expiresRaw.replaceAll(' ', 'T'))
                  : DateTime.now().add(const Duration(days: 30));

              if (newCookie != null && newCookie.isNotEmpty) {
                await sl<SecureStorageHelper>().saveMadrasatiSession(
                  MadrasatiSessionData(
                    sessionCookie: newCookie,
                    schoolId: schoolId,
                    expiresAt: expiry,
                    refreshToken: newRT ?? refreshToken,
                  ),
                );
                debugPrint('💾 [DEBUG] New session saved to SecureStorage ✅');
              }
            }
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ تم تجديد الجلسة: $message'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          } else {
            // ❌ الباك رفض — لازم يعمل connect من أول
            debugPrint('🔐 [DEBUG] success=false — showing SessionExpiredDialog');
            if (mounted) SessionExpiredDialog.show(context);
          }
        },
      );
    } catch (e, st) {
      // خطأ غير متوقع — نفرّق شبكة من غيره
      final isNetworkError = e.toString().toLowerCase().contains('socket') ||
          e.toString().toLowerCase().contains('connection') ||
          e.toString().toLowerCase().contains('timeout');
      debugPrint('💥 [DEBUG] Exception: $e');
      debugPrint('   StackTrace: $st');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      if (mounted) {
        if (isNetworkError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📵 تحقق من اتصال الإنترنت وحاول مجدداً'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        } else {
          SessionExpiredDialog.show(context);
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.withValues(alpha: 0.5), width: 1.5),
        borderRadius: BorderRadius.circular(12),
        color: Colors.red.withValues(alpha: 0.06),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _loading ? null : _triggerRefresh,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: _loading
                ? const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.refresh_rounded,
                          color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'DEBUG — اختبار تجديد جلسة مدرستي',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

