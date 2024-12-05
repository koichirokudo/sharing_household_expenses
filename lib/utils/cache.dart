Map<String, Map<String, dynamic>> cachedData = {};

void clearCache(String key) {
  cachedData.remove(key);
}

void clearAllCache() {
  cachedData.clear();
}
