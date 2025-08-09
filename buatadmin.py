from app import app, db
from routes.models import User
from werkzeug.security import generate_password_hash

with app.app_context():
    # Hash password
    hashed_password = generate_password_hash('admin123', method='pbkdf2:sha256')

    # Buat user admin baru
    admin_user = User(
        name='admin',
        dob='1990-01-01',  # Ganti dengan tanggal lahir yang sesuai
        gender='Laki-laki',  # Ganti dengan gender yang sesuai
        email='admin@patani.com',
        phone='081234567890',  # Ganti dengan nomor telepon yang sesuai
        password=hashed_password,
        role='admin',
        region='Aceh',
        latitude=-6.2088,
        longitude=106.8456
    )

    # Tambahkan ke database
    db.session.add(admin_user)
    db.session.commit()
    print("User admin berhasil dibuat!")
