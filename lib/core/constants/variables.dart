class Variables {
  static const String appName = 'Kasau Absence Application';
  static const String baseUrl = 'http://192.168.1.28:8000';
  
  /// Constructs a full image URL from a relative path
  static String getImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return '';
    }
    
    // If it's already a full URL, return as is
    if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
      return relativePath;
    }
    
    // If it's a relative path, construct the full URL
    if (relativePath.startsWith('/')) {
      return '$baseUrl$relativePath';
    }
    
    // If it doesn't start with /, add it
    return '$baseUrl/$relativePath';
  }
  
  /// Gets alternative URL patterns for testing
  static List<String> getImageUrlPatterns(String relativePath) {
    if (relativePath.startsWith('/storage/')) {
      return [
        '$baseUrl$relativePath',                    // /storage/profile_images/...
        '$baseUrl/public$relativePath',             // /public/storage/profile_images/...
        '$baseUrl/storage/app/public${relativePath.replaceFirst('/storage/', '/')}', // /storage/app/public/profile_images/...
      ];
    }
    return ['$baseUrl$relativePath'];
  }
} 