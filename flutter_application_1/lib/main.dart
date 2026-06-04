import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: GirisSayfasi()));
}

class GirisSayfasi extends StatefulWidget {
  @override
  GirisSayfasiState createState() => GirisSayfasiState();
}

class GirisSayfasiState extends State<GirisSayfasi> {
  var emailkontrol = TextEditingController();
  var sifrekontrol = TextEditingController();

  girisYap() async {
    var url = Uri.parse("http://127.0.0.1:8000/giris/");
    var cevap = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "eposta": emailkontrol.text,
        "Sifre": sifrekontrol.text,
      }),
    );

    if (cevap.statusCode == 200) {
      var veri = jsonDecode(cevap.body);
      if (veri['id'] != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DersListesiSayfasi(kullaniciId: veri['id']),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Giriş Başarısız!"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Akademi Giriş Sistemi"), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailkontrol,
              decoration: InputDecoration(
                labelText: "E-Posta",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: sifrekontrol,
              decoration: InputDecoration(
                labelText: "Şifre",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: girisYap,
                child: Text("GİRİŞ YAP", style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => KayitSayfasi()),
                );
              },
              child: Text(
                "Hesabın yok mu? Yeni Kayıt Oluştur",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KayitSayfasi extends StatefulWidget {
  @override
  _KayitSayfasiState createState() => _KayitSayfasiState();
}

class _KayitSayfasiState extends State<KayitSayfasi> {
  var adKontrol = TextEditingController();
  var emailKontrol = TextEditingController();
  var sifreKontrol = TextEditingController();
  var bolumKontrol = TextEditingController();

  kayitOl() async {
    var url = Uri.parse("http://127.0.0.1:8000/kayit/");
    var cevap = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "Ad_soyad": adKontrol.text,
        "eposta": emailKontrol.text,
        "Sifre": sifreKontrol.text,
        "Bolum": bolumKontrol.text,
      }),
    );

    if (cevap.statusCode == 200 || cevap.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text("Kayıt Başarılı! Şimdi giriş yapabilirsiniz."),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Kayıt Başarısız! Bilgileri kontrol edin."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Yeni Kullanıcı Kaydı"), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add, size: 60, color: Colors.blue),
              SizedBox(height: 20),
              TextField(
                controller: adKontrol,
                decoration: InputDecoration(
                  labelText: "Ad Soyad",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: emailKontrol,
                decoration: InputDecoration(
                  labelText: "E-Posta",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: sifreKontrol,
                decoration: InputDecoration(
                  labelText: "Şifre",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 15),
              TextField(
                controller: bolumKontrol,
                decoration: InputDecoration(
                  labelText: "Bölüm",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: kayitOl,
                  child: Text(
                    "KAYIT OL",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DersListesiSayfasi extends StatefulWidget {
  final int kullaniciId;
  DersListesiSayfasi({required this.kullaniciId});

  @override
  _DersListesiSayfasiState createState() => _DersListesiSayfasiState();
}

class _DersListesiSayfasiState extends State<DersListesiSayfasi> {
  List dersler = [];

  @override
  void initState() {
    super.initState();
    dersleriGetir();
  }

  dersleriGetir() async {
    var url = Uri.parse("http://127.0.0.1:8000/dersler/${widget.kullaniciId}");
    var cevap = await http.get(url);
    if (cevap.statusCode == 200) {
      setState(() {
        dersler = jsonDecode(cevap.body);
      });
    }
  }

  dersiSil(int dersId) async {
    var url = Uri.parse("http://127.0.0.1:8000/ders-sil/$dersId");
    var cevap = await http.delete(url);
    if (cevap.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.green, content: Text("Ders silindi!")),
      );
      dersleriGetir();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Silme başarısız!"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Derslerim")),
      body: dersler.isEmpty
          ? Center(child: Text("Ders bulunamadı."))
          : ListView.builder(
              itemCount: dersler.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: Icon(Icons.menu_book, color: Colors.blue),
                    title: Text(
                      dersler[index]['Ders_adi'] ?? "Eksik Veri",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Hoca: ${dersler[index]['Hoca_adi'] ?? 'Yok'}",
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => dersiSil(dersler[index]['id']),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DersDetaySayfasi(dersId: dersler[index]['id']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? eklendi = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DersEkleSayfasi(kullaniciId: widget.kullaniciId),
            ),
          );
          if (eklendi == true) {
            dersleriGetir();
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class DersEkleSayfasi extends StatefulWidget {
  final int kullaniciId;
  DersEkleSayfasi({required this.kullaniciId});

  @override
  _DersEkleSayfasiState createState() => _DersEkleSayfasiState();
}

class _DersEkleSayfasiState extends State<DersEkleSayfasi> {
  var dersAdiKontrol = TextEditingController();
  var hocaAdiKontrol = TextEditingController();

  dersEkle() async {
    var url = Uri.parse("http://127.0.0.1:8000/ders-ekle/");
    var cevap = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "Ders_adi": dersAdiKontrol.text,
        "Hoca_adi": hocaAdiKontrol.text,
        "Kullanici_id": widget.kullaniciId,
      }),
    );

    if (cevap.statusCode == 200 || cevap.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Ders eklenemedi!"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Yeni Ders Ekle")),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: dersAdiKontrol,
              decoration: InputDecoration(
                labelText: "Ders Adı",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: hocaAdiKontrol,
              decoration: InputDecoration(
                labelText: "Hoca Adı",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: dersEkle,
                child: Text(
                  "DERSİ KAYDET",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DersDetaySayfasi extends StatefulWidget {
  final int dersId;
  DersDetaySayfasi({required this.dersId});

  @override
  _DersDetaySayfasiState createState() => _DersDetaySayfasiState();
}

class _DersDetaySayfasiState extends State<DersDetaySayfasi> {
  String limitBilgisi = "Yükleniyor...";
  String kalanHakBilgisi = "";
  int? programId;
  String programBilgisi = "Program aranıyor...";
  Color kalanHakRengi = Colors.black;

  var gunKontrol = TextEditingController();
  var basatKontrol = TextEditingController();
  var bitsatKontrol = TextEditingController();

  var maksDvmKontrol = TextEditingController();
  var uyariKontrol = TextEditingController();

  @override
  void initState() {
    super.initState();
    verileriTopla();
  }

  verileriTopla() async {
    var analizCevap = await http.get(
      Uri.parse("http://127.0.0.1:8000/ders-analiz/${widget.dersId}"),
    );
    if (analizCevap.statusCode == 200) {
      var analiz = jsonDecode(analizCevap.body);
      setState(() {
        limitBilgisi = analiz['limit_metni'];
        int kalan = analiz['kalan_hak'];
        kalanHakBilgisi = "Kalan Devamsızlık Hakkı: $kalan";
        if (kalan <= (analiz['uyari_siniri'] ?? 0)) {
          kalanHakRengi = Colors.red;
        } else {
          kalanHakRengi = Colors.green;
        }
      });
    }

    var programCevap = await http.get(
      Uri.parse("http://127.0.0.1:8000/programlar/${widget.dersId}"),
    );
    if (programCevap.statusCode == 200) {
      List programlar = jsonDecode(programCevap.body);
      if (programlar.isNotEmpty) {
        setState(() {
          programId = programlar[0]['id'];
          programBilgisi =
              "Ders Saati: ${programlar[0]['Gun']} | ${programlar[0]['basat']} - ${programlar[0]['bitsat']}";
        });
      } else {
        setState(() => programBilgisi = "Bu derse ait bir program bulunamadı.");
      }
    }
  }

  limitEkle() async {
    var url = Uri.parse("http://127.0.0.1:8000/limit-ekle/");
    var cevap = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "ders_id": widget.dersId,
        "maks_dvm": int.tryParse(maksDvmKontrol.text) ?? 0,
        "uyari": int.tryParse(uyariKontrol.text) ?? 0,
      }),
    );
    if (cevap.statusCode == 200 || cevap.statusCode == 201) {
      Navigator.pop(context);
      verileriTopla();
    }
  }

  programEkle() async {
    var url = Uri.parse("http://127.0.0.1:8000/program-ekle/");
    var cevap = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "ders_id": widget.dersId,
        "Gun": gunKontrol.text,
        "basat": basatKontrol.text,
        "bitsat": bitsatKontrol.text,
      }),
    );
    if (cevap.statusCode == 200 || cevap.statusCode == 201) {
      Navigator.pop(context);
      verileriTopla();
    }
  }

  yoklamaEkle(String durum) async {
    if (programId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Hata: Önce derse bir Program eklenmeli!"),
        ),
      );
      return;
    }

    var url = Uri.parse("http://127.0.0.1:8000/yoklama-ekle/");
    var cevap = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "Program_id": programId,
        "Tarih": DateTime.now().toIso8601String().split('T')[0],
        "Durum": durum,
        "Notlar": "Mobil uygulamadan eklendi",
      }),
    );

    if (cevap.statusCode == 200 || cevap.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text("Yoklama ($durum) başarıyla veritabanına işlendi!"),
        ),
      );
      verileriTopla();
    }
  }

  limitDialogGoster() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Limit Ekle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: maksDvmKontrol,
              decoration: InputDecoration(labelText: "Maksimum Devamsızlık"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: uyariKontrol,
              decoration: InputDecoration(labelText: "Uyarı Sınırı"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [ElevatedButton(onPressed: limitEkle, child: Text("Kaydet"))],
      ),
    );
  }

  programDialogGoster() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Program Ekle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: gunKontrol,
              decoration: InputDecoration(labelText: "Gün"),
            ),
            TextField(
              controller: basatKontrol,
              decoration: InputDecoration(labelText: "Başlangıç (Örn: 09:00)"),
            ),
            TextField(
              controller: bitsatKontrol,
              decoration: InputDecoration(labelText: "Bitiş (Örn: 10:30)"),
            ),
          ],
        ),
        actions: [
          ElevatedButton(onPressed: programEkle, child: Text("Kaydet")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ders İşlemleri")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 40),
                    SizedBox(height: 10),
                    Text(
                      limitBilgisi,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      kalanHakBilgisi,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: kalanHakRengi,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.access_time, color: Colors.orange, size: 40),
                    SizedBox(height: 10),
                    Text(
                      programBilgisi,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: limitDialogGoster,
                  child: Text("LİMİT EKLE"),
                ),
                ElevatedButton(
                  onPressed: programDialogGoster,
                  child: Text("PROGRAM EKLE"),
                ),
              ],
            ),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.check, color: Colors.white),
                    label: Text(
                      "GELDİM",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.all(15),
                    ),
                    onPressed: programId != null
                        ? () => yoklamaEkle("Geldi")
                        : null,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.close, color: Colors.white),
                    label: Text(
                      "GELMEDİM",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.all(15),
                    ),
                    onPressed: programId != null
                        ? () => yoklamaEkle("Gelmedi")
                        : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
