from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()

class WaterSample(db.Model):
    __tablename__ = 'water_samples'
    
    id = db.Column(db.Integer, primary_key=True)
    location = db.Column(db.String(100), nullable=False)
    state = db.Column(db.String(50), nullable=False)
    district = db.Column(db.String(50), nullable=False)
    ph = db.Column(db.Float, nullable=False)
    turbidity = db.Column(db.Float, nullable=False)
    bacterial_count = db.Column(db.Float, nullable=False)
    temperature = db.Column(db.Float, nullable=False)
    contamination_level = db.Column(db.String(20), nullable=False)
    sample_date = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'location': self.location,
            'state': self.state,
            'district': self.district,
            'ph': self.ph,
            'turbidity': self.turbidity,
            'bacterial_count': self.bacterial_count,
            'temperature': self.temperature,
            'contamination_level': self.contamination_level,
            'sample_date': self.sample_date.isoformat()
        }

class DiseaseAlert(db.Model):
    __tablename__ = 'disease_alerts'
    
    id = db.Column(db.Integer, primary_key=True)
    disease = db.Column(db.String(50), nullable=False)
    cases = db.Column(db.Integer, nullable=False)
    risk_level = db.Column(db.String(20), nullable=False)
    location = db.Column(db.String(100), nullable=False)
    state = db.Column(db.String(50), nullable=False)
    district = db.Column(db.String(50), nullable=False)
    reported_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'disease': self.disease,
            'cases': self.cases,
            'risk_level': self.risk_level,
            'location': self.location,
            'state': self.state,
            'district': self.district,
            'reported_at': self.reported_at.isoformat()
        }

class Prediction(db.Model):
    __tablename__ = 'predictions'
    
    id = db.Column(db.Integer, primary_key=True)
    ph = db.Column(db.Float, nullable=False)
    turbidity = db.Column(db.Float, nullable=False)
    bacterial_count = db.Column(db.Float, nullable=False)
    temperature = db.Column(db.Float, nullable=False)
    location = db.Column(db.String(100), nullable=False)
    risk = db.Column(db.String(20), nullable=False)
    score = db.Column(db.Float, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'ph': self.ph,
            'turbidity': self.turbidity,
            'bacterial_count': self.bacterial_count,
            'temperature': self.temperature,
            'location': self.location,
            'risk': self.risk,
            'score': self.score,
            'created_at': self.created_at.isoformat()
        }

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    password = db.Column(db.String(100), nullable=False)
    role = db.Column(db.String(20), nullable=False)
    
    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username,
            'role': self.role
        }