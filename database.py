from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Veritabanı dosyasının yolu
SQLALCHEMY_DATABASE_URL = "sqlite:///./devamsizlik.db"

# 1. Motoru oluştur (main.py bunu 'motor' adıyla bekliyor)
motor = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)

# 2. Veritabanı oturum fabrikası
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=motor)

# 3. Modellerin miras alacağı ana sınıf (models.py bunu 'Base' adıyla bekliyor)
# JUNIOR HATASI BURADAYDI: Bu nesne burada YARATILMALI, import edilmemeli!
Base = declarative_base()

# 4. Veritabanı bağlantı fonksiyonu (main.py bunu 'al_db' adıyla bekliyor)
def al_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()