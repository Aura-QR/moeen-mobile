/// Conditionally exports the correct [openUrlInNewTab] implementation
/// depending on the compile-time platform:
///   • dart.library.html  → web  → [platform_url_web.dart]
///   • everything else    → stub → [platform_url_stub.dart]
export 'platform_url_stub.dart'
    if (dart.library.html) 'platform_url_web.dart';
