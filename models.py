from sqlalchemy import Column, Integer, String, ForeignKey, Date
from sqlalchemy.orm import relationship
from database import Base # database.py dosyasında oluşturduğun Base'i çağırıyoruz

class Kullanici(Base):
    __tablename__ = "Kullanicilar"

    id = Column(Integer, primary_key=True, index=True)
    Ad_soyad = Column(String, nullable=False)
    eposta = Column(String, unique=True, index=True, nullable=False)
    Sifre = Column(String, nullable=False)
    Bolum = Column(String)

    # İlişki: Bir kullanıcının birden fazla dersi olabilir
    dersler = relationship("Ders", back_populates="ogrenci", cascade="all, delete-orphan")


class Ders(Base):
    __tablename__ = "Dersler"

    id = Column(Integer, primary_key=True, index=True)
    Ders_adi = Column(String, nullable=False)
    Hoca_adi = Column(String)
    Kullanici_id = Column(Integer, ForeignKey("Kullanicilar.id"))

    # İlişkiler
    ogrenci = relationship("Kullanici", back_populates="dersler")
    programlar = relationship("Program", back_populates="ders", cascade="all, delete-orphan")
    limit = relationship("Limit", back_populates="ders", uselist=False, cascade="all, delete-orphan")


class Program(Base):
    __tablename__ = "Program"

    id = Column(Integer, primary_key=True, index=True)
    ders_id = Column(Integer, ForeignKey("Dersler.id"))
    Gun = Column(String, nullable=False)
    basat = Column(String, nullable=False) # "09:00"
    bitsat = Column(String, nullable=False)    # "10:30"

    # İlişkiler
    ders = relationship("Ders", back_populates="programlar")
    yoklamalar = relationship("YoklamaKaydi", back_populates="program", cascade="all, delete-orphan")


class YoklamaKaydi(Base):
    __tablename__ = "Yoklama_Kayitlari"

    id = Column(Integer, primary_key=True, index=True)
    Program_id = Column(Integer, ForeignKey("Program.id"))
    Tarih = Column(String, nullable=False) # "2026-03-25"
    Durum = Column(String, nullable=False) # "Geldi", "Gelmedi", "İzinli"
    Notlar = Column(String)

    # İlişki
    program = relationship("Program", back_populates="yoklamalar")


class Limit(Base):
    __tablename__ = "Limitler"

    id = Column(Integer, primary_key=True, index=True)
    ders_id = Column(Integer, ForeignKey("Dersler.id"), unique=True)
    maks_dvm = Column(Integer, nullable=False)
    uyari = Column(Integer)

    # İlişki
    ders = relationship("Ders", back_populates="limit")
