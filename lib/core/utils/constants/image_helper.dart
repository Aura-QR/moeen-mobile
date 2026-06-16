import 'package:moean/core/network/remote/api_endpoints.dart';

class ImageHelper {
  /// Builds a robust image URL by prepending the base URL and handling common subfolders.
  /// It covers cases where the backend returns relative paths like 'avatars/xxx.jpg'
  /// and ensures Laravel's '/storage/' prefix is added if likely needed.
  static String? getFullImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;

    final trimmedPath = path.trim();

    // 1. If it's already a full URL, just ensure it's HTTPS if needed
    if (trimmedPath.startsWith('http')) {
      if (trimmedPath.startsWith('http://') && baseUrl.startsWith('https://')) {
        return trimmedPath.replaceFirst('http://', 'https://');
      }
      return trimmedPath;
    }

    // 2. Prepare the base and relative path
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    String relativePath = trimmedPath.startsWith('/')
        ? trimmedPath.substring(1)
        : trimmedPath;

    // 3. Heuristics for common subfolders that usually live under /storage/
    // We check if it doesn't already have storage/ or public/
    final List<String> storageFolders = [
      'avatars',
      'profiles',
      'patients',
      'doctors',
      'facilities',
      'medications',
      'prescriptions',
    ];

    bool needsStoragePrefix = true;
    if (relativePath.startsWith('storage/') ||
        relativePath.startsWith('public/')) {
      needsStoragePrefix = false;
    } else {
      // Check if it starts with any common storage folder
      bool isMatch = false;
      for (var folder in storageFolders) {
        if (relativePath.startsWith('$folder/')) {
          isMatch = true;
          break;
        }
      }
      if (!isMatch) {
        // If it doesn't match a known folder, we still might need storage/
        // but we'll be more conservative.
        // Let's assume for now that if it's relative, it needs storage/
        // UNLESS the path starts with something like 'api/'
        if (relativePath.startsWith('api/')) {
          needsStoragePrefix = false;
        }
      }
    }

    if (needsStoragePrefix) {
      relativePath = 'storage/$relativePath';
    }

    return '$base/$relativePath';
  }
}
