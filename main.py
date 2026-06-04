from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
import models, schemas
from database import motor, al_db
from security import sifre_dogrula, sifre_ozetle
from fastapi.middleware.cors import CORSMiddleware


models.Base.metadata.create_all(bind=motor)

uygulama = FastAPI(title="Akademi Takip Sistemi API")

uygulama.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)


@uygulama.post("/kayit/", response_model=schemas.Kullanici)
def kullanici_olustur(kullanici: schemas.KullaniciCreate, db: Session = Depends(al_db)):
    if db.query(models.Kullanici).filter(models.Kullanici.eposta == kullanici.eposta).first():
        raise HTTPException(status_code=400, detail="Bu e-posta adresi zaten kayıtlı!")
    
    yeni_kullanici = models.Kullanici(
        Ad_soyad=kullanici.Ad_soyad,
        eposta=kullanici.eposta,
        Sifre=sifre_ozetle(kullanici.Sifre), 
        Bolum=kullanici.Bolum
    )
    db.add(yeni_kullanici)
    db.commit()
    db.refresh(yeni_kullanici)
    return yeni_kullanici

@uygulama.post("/giris/")
def giris_yap(kullanici_bilgileri: schemas.KullaniciGiris, db: Session = Depends(al_db)):
    db_kullanici = db.query(models.Kullanici).filter(models.Kullanici.eposta == kullanici_bilgileri.eposta).first()

    if not db_kullanici or not sifre_dogrula(kullanici_bilgileri.Sifre, db_kullanici.Sifre):
        raise HTTPException(status_code=401, detail="Geçersiz e-posta veya şifre!")   

    return {"mesaj": "Giriş başarılı!", "id": db_kullanici.id}   



@uygulama.post("/ders-ekle/", response_model=schemas.Ders)
def ders_olustur(ders: schemas.DersCreate, db: Session = Depends(al_db)):
    yeni_ders = models.Ders(
        Ders_adi=ders.Ders_adi,
        Hoca_adi=ders.Hoca_adi,
        Kullanici_id=ders.Kullanici_id
    ) 
    db.add(yeni_ders)
    db.commit()
    db.refresh(yeni_ders)
    return yeni_ders

@uygulama.get("/dersler/{kullanici_id}", response_model=List[schemas.Ders])
def dersleri_listele(kullanici_id: int, db: Session = Depends(al_db)):
    dersler = db.query(models.Ders).filter(models.Ders.Kullanici_id == kullanici_id).all()
    if not dersler:
        return []
    return dersler



@uygulama.post("/program-ekle/", response_model=schemas.Program)
def program_ekle(program: schemas.ProgramCreate, db: Session = Depends(al_db)):
    yeni_program = models.Program(
        ders_id=program.ders_id,
        Gun=program.Gun,
        basat=program.basat,
        bitsat=program.bitsat
    )
    db.add(yeni_program)
    db.commit()
    db.refresh(yeni_program)
    return yeni_program

@uygulama.get("/programlar/{ders_id}", response_model=List[schemas.Program])
def programlari_getir(ders_id: int, db: Session = Depends(al_db)):
    return db.query(models.Program).filter(models.Program.ders_id == ders_id).all()



@uygulama.post("/yoklama-ekle/", response_model=schemas.Yoklama)
def yoklama_ekle(yoklama: schemas.YoklamaCreate, db: Session = Depends(al_db)):
    yeni_yoklama = models.YoklamaKaydi(
        Program_id=yoklama.Program_id,
        Tarih=yoklama.Tarih,
        Durum=yoklama.Durum,
        Notlar=yoklama.Notlar
    )
    db.add(yeni_yoklama)
    db.commit()
    db.refresh(yeni_yoklama)
    return yeni_yoklama

@uygulama.get("/yoklamalar/{program_id}", response_model=List[schemas.Yoklama])
def yoklamalari_getir(program_id: int, db: Session = Depends(al_db)):
    return db.query(models.YoklamaKaydi).filter(models.YoklamaKaydi.Program_id == program_id).all()


@uygulama.post("/limit-ekle/", response_model=schemas.Limit)
def limit_ekle(limit_veri: schemas.LimitCreate, db: Session = Depends(al_db)):
    yeni_limit = models.Limit(
        ders_id=limit_veri.ders_id,
        maks_dvm=limit_veri.maks_dvm,
        uyari=limit_veri.uyari
    )
    db.add(yeni_limit)
    db.commit()
    db.refresh(yeni_limit)
    return yeni_limit

@uygulama.get("/limit/{ders_id}", response_model=schemas.Limit)
def limit_getir(ders_id: int, db: Session = Depends(al_db)):
    limit = db.query(models.Limit).filter(models.Limit.ders_id == ders_id).first()
    if not limit:
        raise HTTPException(status_code=404, detail="Bu ders için limit atanmamış.")
    return limit

@uygulama.get("/ders-analiz/{ders_id}")
def ders_analizi_getir(ders_id: int, db: Session = Depends(al_db)):
    limit = db.query(models.Limit).filter(models.Limit.ders_id == ders_id).first()
    if not limit:
        return {
            "limit_metni": "Limit atanmamış",
            "kalan_hak": 0,
            "durum_rengi": "siyah"
        }
    
    gelmedi_sayisi = db.query(models.YoklamaKaydi).join(models.Program).filter(
        models.Program.ders_id == ders_id,
        models.YoklamaKaydi.Durum == "Gelmedi"
    ).count()
    
    kalan_hak = limit.maks_dvm - gelmedi_sayisi
    
    return {
        "limit_metni": "Maksimum: " + str(limit.maks_dvm) + " | Toplam Gelmedi: " + str(gelmedi_sayisi),
        "kalan_hak": kalan_hak,
        "uyari_siniri": limit.uyari
    }
@uygulama.delete("/ders-sil/{ders_id}")
def ders_sil(ders_id: int, db: Session = Depends(al_db)):
    silinecek_ders = db.query(models.Ders).filter(models.Ders.id == ders_id).first()
    if not silinecek_ders:
        raise HTTPException(status_code=404, detail="Ders bulunamadı")
    db.delete(silinecek_ders)
    db.commit()
    return {"mesaj": "Ders ve bağlı tüm veriler silindi"}