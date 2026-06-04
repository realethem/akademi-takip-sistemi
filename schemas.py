from pydantic import BaseModel, EmailStr
from typing import Optional


class KullaniciBase(BaseModel):
    Ad_soyad: str
    eposta: EmailStr
    Bolum: Optional[str] = None

class KullaniciCreate(KullaniciBase):
    Sifre: str  

class KullaniciGiris(BaseModel):
    eposta: EmailStr
    Sifre: str

class Kullanici(KullaniciBase):
    id: int
    
    class Config:
        from_attributes = True 


class DersBase(BaseModel):
    Ders_adi: str
    Hoca_adi: Optional[str] = None

class DersCreate(DersBase):
    Kullanici_id: int


class Ders(DersBase):
    id: int
    Kullanici_id: int
    
    class Config:
        from_attributes = True

class ProgramBase(BaseModel):
    Gun: str
    basat: str
    bitsat: str

class ProgramCreate(ProgramBase):
    ders_id: int

class Program(ProgramBase):
    id: int
    ders_id: int

    class Config:
        from_attributes = True


class YoklamaBase(BaseModel):
    Tarih: str
    Durum: str
    Notlar: Optional[str] = None

class YoklamaCreate(YoklamaBase):
    Program_id: int

class Yoklama(YoklamaBase):
    id: int
    Program_id: int

    class Config:
        from_attributes = True


class LimitBase(BaseModel):
    maks_dvm: int
    uyari: int

class LimitCreate(LimitBase):
    ders_id: int

class Limit(LimitBase):
    id: int
    ders_id: int

    class Config:
        from_attributes = True