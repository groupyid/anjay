from datetime import datetime
from flask_sqlalchemy import SQLAlchemy
from datetime import date

db = SQLAlchemy()

class User(db.Model):
    __tablename__ = 'user'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    dob = db.Column(db.Date, nullable=False, default=date(2000, 1, 1))
    gender = db.Column(db.String(10), nullable=False)
    email = db.Column(db.String(255), nullable=False, unique=True)
    phone = db.Column(db.String(20), nullable=False)
    password = db.Column(db.String(255), nullable=False)
    role = db.Column(db.String(20), default='petani')
    region = db.Column(db.String(100))  # Keep for backward compatibility
    province_id = db.Column(db.Integer, db.ForeignKey('province.id'), nullable=True)
    regency_id = db.Column(db.Integer, db.ForeignKey('regency.id'), nullable=True)
    profile_pic = db.Column(db.String(255))
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    province = db.relationship('Province', backref=db.backref('users', lazy=True))
    regency = db.relationship('Regency', backref=db.backref('users', lazy=True))




class ChatHistory(db.Model):
    session_id = db.Column(db.String(64), nullable=False, index=True)
    __tablename__ = 'chat_history'
    id = db.Column(db.Integer, primary_key=True)
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

