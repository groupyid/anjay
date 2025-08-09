import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

# Ambil URL database dari variabel lingkungan
database_url = os.environ.get('DATABASE_URL')
if not database_url:
    # Fallback jika variabel lingkungan tidak ditemukan
    # Pastikan mengganti dengan koneksi database lokalmu
    database_url = "postgresql://postgres:Gemastikusk23@localhost:5432/agrolldb"

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = database_url
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# --- Model-model yang kamu berikan ---
class User(db.Model):
    __tablename__ = 'user'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    dob = db.Column(db.Date, nullable=False)
    gender = db.Column(db.String(10), nullable=False)
    email = db.Column(db.String(255), nullable=False, unique=True)
    phone = db.Column(db.String(20), nullable=False)
    password = db.Column(db.String(255), nullable=False)
    role = db.Column(db.String(20), default='petani')
    region = db.Column(db.String(100))
    profile_pic = db.Column(db.String(255))
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class ChatHistory(db.Model):
    __tablename__ = 'chat_history'
    id = db.Column(db.Integer, primary_key=True)
    session_id = db.Column(db.String(64), nullable=False, index=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id', ondelete='CASCADE'), nullable=True)
    question = db.Column(db.Text, nullable=False)
    answer = db.Column(db.Text, nullable=False)
    sources = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    user = db.relationship('User', backref=db.backref('chat_histories', lazy=True))

class Region(db.Model):
    __tablename__ = 'region'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(150), unique=True, nullable=False)

class Province(db.Model):
    __tablename__ = 'province'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(150), unique=True, nullable=False)

class Regency(db.Model):
    __tablename__ = 'regency'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(150), nullable=False)
    province_id = db.Column(db.Integer, db.ForeignKey('province.id', ondelete='CASCADE'), nullable=False)
    province = db.relationship('Province', backref=db.backref('regencies', lazy=True))

# --- Akhir model ---

def create_tables():
    """Membuat semua tabel database berdasarkan model SQLAlchemy."""
    with app.app_context():
        db.create_all()
        print("Semua tabel telah berhasil dibuat di database PostgreSQL.")

if __name__ == '__main__':
    create_tables()
