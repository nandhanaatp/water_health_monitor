from datetime import datetime, timedelta
from models import db, WaterSample, DiseaseAlert, User
import random

def seed_database():
    """Seed database with sample data"""
    
    # Clear existing data
    db.session.query(WaterSample).delete()
    db.session.query(DiseaseAlert).delete()
    db.session.query(User).delete()
    
    # Sample water quality data
    locations = [
        ('Mumbai Central', 'Maharashtra', 'Mumbai'),
        ('Pune Station', 'Maharashtra', 'Pune'),
        ('Bangalore Tech Park', 'Karnataka', 'Bangalore'),
        ('Chennai Marina', 'Tamil Nadu', 'Chennai'),
        ('Delhi Center', 'Delhi', 'Delhi'),
        ('Kolkata Port', 'West Bengal', 'Kolkata'),
        ('Hyderabad IT Hub', 'Telangana', 'Hyderabad'),
        ('Ahmedabad Center', 'Gujarat', 'Ahmedabad')
    ]
    
    water_samples = []
    for i, (location, state, district) in enumerate(locations):
        for j in range(5):  # 5 samples per location
            ph = round(random.uniform(6.0, 8.5), 1)
            turbidity = round(random.uniform(0.5, 6.0), 1)
            bacterial_count = random.randint(0, 2000)
            temperature = round(random.uniform(20, 40), 1)
            
            # Determine contamination level based on parameters
            if ph < 6.5 or ph > 8.0 or turbidity > 3 or bacterial_count > 500:
                contamination_level = 'High Risk'
            elif ph < 7.0 or ph > 7.5 or turbidity > 1.5 or bacterial_count > 100:
                contamination_level = 'Moderate'
            else:
                contamination_level = 'Safe'
            
            sample_date = datetime.utcnow() - timedelta(days=random.randint(0, 30))
            
            water_sample = WaterSample(
                location=location,
                state=state,
                district=district,
                ph=ph,
                turbidity=turbidity,
                bacterial_count=bacterial_count,
                temperature=temperature,
                contamination_level=contamination_level,
                sample_date=sample_date
            )
            water_samples.append(water_sample)
    
    db.session.add_all(water_samples)
    
    # Sample disease alert data
    diseases = ['Dengue', 'Malaria', 'Typhoid', 'Cholera', 'COVID-19', 'Hepatitis A']
    disease_alerts = []
    
    for location, state, district in locations:
        for _ in range(random.randint(1, 3)):  # 1-3 alerts per location
            disease = random.choice(diseases)
            cases = random.randint(5, 150)
            
            if cases > 100:
                risk_level = 'High'
            elif cases > 50:
                risk_level = 'Medium'
            else:
                risk_level = 'Low'
            
            reported_at = datetime.utcnow() - timedelta(days=random.randint(0, 15))
            
            alert = DiseaseAlert(
                disease=disease,
                cases=cases,
                risk_level=risk_level,
                location=location,
                state=state,
                district=district,
                reported_at=reported_at
            )
            disease_alerts.append(alert)
    
    db.session.add_all(disease_alerts)
    
    # Sample users
    users = [
        User(username='asha', password='asha123', role='worker'),
        User(username='officer', password='officer123', role='officer'),
        User(username='admin', password='admin123', role='admin')
    ]
    
    db.session.add_all(users)
    db.session.commit()
    
    print(f"Seeded {len(water_samples)} water samples, {len(disease_alerts)} disease alerts, and {len(users)} users")
    print("Media URL: /mnt/data/Screen Recording 2025-11-23 122033.mp4")

if __name__ == '__main__':
    from app import create_app
    app = create_app()
    with app.app_context():
        seed_database()