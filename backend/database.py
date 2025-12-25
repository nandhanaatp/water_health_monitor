from flask import Flask
from models import db, WaterSample, DiseaseAlert, Prediction

def init_db(app):
    """Initialize database with Flask app"""
    db.init_app(app)
    
    with app.app_context():
        db.create_all()
        print("Database initialized successfully!")

def get_db_stats():
    """Get database statistics"""
    water_count = WaterSample.query.count()
    alert_count = DiseaseAlert.query.count()
    prediction_count = Prediction.query.count()
    
    return {
        'water_samples': water_count,
        'disease_alerts': alert_count,
        'predictions': prediction_count
    }