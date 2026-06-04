import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServis {
  final String baseUrl = 'http://127.0.0.1:8000'; // API'nin temel URL'si
  Future<void> kayit_ol(String adSoyad, String eposta, String sifre) async {
    final response = await http.post(
      Uri.parse('$baseUrl/kayit_ol'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Ad_soyad': adSoyad,
        'eposta': eposta,
        'Sifre': sifre,
        'Bolum': 'Bilgisayar Mühendisliği',
      }),
    );
    if (response.statusCode == 200) {
      // Kayıt başarılı
      print('Kayıt başarılı');
    } else {
      // Kayıt başarısız
      print('Kayıt başarısız: ${response.body}');
    }
  }
}
