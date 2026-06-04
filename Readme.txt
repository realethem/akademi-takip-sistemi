AKADEMİ TAKİP SİSTEMİ (MVP) - README

Bu proje, bir üniversite akademisi bünyesindeki öğrencilerin ders kayıtlarını, ders programlarını, devamsızlık limitlerini ve yoklama durumlarını uçtan uca takip eden katmanlı bir yazılım mimarisidir. Proje, modern yazılım standartlarına uygun olarak Backend (FastAPI) ve Frontend (Flutter) olmak üzere iki ana modülden oluşmaktadır.

---

1. MİMARİ VE TEKNOLOJİK YAPI

Backend (Arka Yüz)
* Framework: FastAPI (Asenkron, yüksek performanslı Python web framework'ü)
* ORM (Object-Relational Mapping): SQLAlchemy (Veritabanı bağımsız veri yönetimi)
* Veri Doğrulama (Data Validation): Pydantic v2 (Şema güvenliği ve gümrük kontrolü)
* Veritabanı: SQLite (İlişkisel veritabanı - RDBMS)
* Güvenlik: Şifreler veritabanında ham metin (plain text) olarak değil, kriptografik olarak özetlenerek (Hash) saklanmaktadır.

Frontend (Ön Yüz)
* Framework: Flutter (Dart mimarisi ile yerel performans)
* Durum Yönetimi: setState (Reaktif UI güncellemeleri)
* İletişim Protokolü: REST API HTTP istekleri (POST, GET, DELETE) üzerinden JSON veri takası.

---

2. İLİŞKİSEL VERİTABANI ŞEMASI (models.py)

Sistem birbiriyle konuşan 5 farklı tablonun tam ilişkisel yapısı üzerine kurulmuştur:

1. Kullanicilar (Kullanici): Sisteme kayıt olan öğrencilerin temel bilgilerini ve özetlenmiş şifrelerini tutar. (Bire-Çok ilişki ile Dersler tablosuna bağlıdır).
2. Dersler (Ders): Sisteme eklenen derslerin adını ve hocasını tutar. cascade="all, delete-orphan" kuralı sayesinde bir ders silindiğinde ona bağlı tüm program, limit ve yoklama kayıtları veritabanından otomatik olarak temizlenir.
3. Program (Program): Derslerin hangi gün, hangi saat aralıklarında yapılacağını tutar.
4. Yoklama_Kayitlari (YoklamaKaydi): Belirli bir ders programına ait "Geldi", "Gelmedi" veya "İzinli" durumlarını tarih bazlı saklar.
5. Limitler (Limit): Her dersin maksimum devamsızlık hakkını ve kritik uyarı sınırını belirler. uselist=False parametresi ile Ders tablosuna Bire-Bir (One-to-One) olarak kilitlenmiştir.

---

3. ÖNE ÇIKAN TEKNİK ÖZELLİKLER VE İŞ MANTIĞI (Business Logic)

* DRY (Don't Repeat Yourself) Prensibi: Pydantic şemalarında KullaniciBase, DersBase gibi temel sınıflar oluşturulmuş, miras alma (Inheritance) yöntemiyle kod tekrarı engellenmiştir.
* Katmanlı Mimari: Veritabanı modelleri (models.py), veri doğrulama şemaları (schemas.py) ve API uç noktaları (main.py) tamamen izole edilerek temiz kod standartları uygulanmıştır.
* Backend Tabanlı Hesaplama: Devamsızlık hakkı hesaplaması istemciye (Flutter) bırakılmamış, backend tarafında JOIN sorgusu kullanılarak dinamik olarak hesaplanmıştır. /ders-analiz/{ders_id} endpoint'i toplam "Gelmedi" sayısını doğrudan veritabanından sayarak kalan hakkı hesaplar.
* Dinamik UI Tepkisi: Öğrencinin kalan devamsızlık hakkı, limit tablosundaki uyarı sınırının altına düştüğünde Flutter arayüzündeki sayaç otomatik olarak kırmızı renge bürünerek kullanıcıyı uyarır.

---

4. SİSTEMİN ÇALIŞTIRILMASI

Backend Kurulumu ve Başlatılması

1. Gerekli Python kütüphanelerini yükleyin (Passlib uyumluluğu için bcrypt sürümü özellikle 4.0.1 olarak sabitlenmiştir):
   pip install fastapi uvicorn sqlalchemy pydantic email-validator passlib "bcrypt==4.0.1"

2. Sunucuyu yerel ağda (localhost) başlatın:
   uvicorn main:uygulama --reload --host 127.0.0.1 --port 8000

3. API dokümantasyonunu ve test arayüzünü görüntülemek için tarayıcıdan şu adrese gidin:
   http://127.0.0.1:8000/docs

Frontend Kurulumu ve Başlatılması

1. Bağımlılıkları çekin:
   flutter pub get

2. Uygulamayı yerel cihazda veya emülatörde çalıştırın:
   flutter run