from passlib.context import CryptContext

# Şifreleme motorunu ayarla
sifre_hash = CryptContext(schemes=["bcrypt"], deprecated="auto")

def sifre_ozetle(sifre: str):
    return sifre_hash.hash(sifre)

def sifre_dogrula(duz_sifre, ozet_sifre):
    return sifre_hash.verify(duz_sifre, ozet_sifre) 