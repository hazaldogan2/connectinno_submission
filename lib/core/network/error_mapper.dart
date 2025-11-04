String mapNetworkError(Object e) {
  final s = e.toString();
  if (s.contains('SocketException')) return 'İnternet bağlantısı yok';
  if (s.contains('404')) return 'Kayıt bulunamadı';
  if (s.contains('401')) return 'Oturum hatası (401)';
  if (s.contains('403')) return 'Yetki yok (403)';
  if (s.contains('timeout')) return 'Zaman aşımı';
  return 'Beklenmeyen hata: $s';
}
