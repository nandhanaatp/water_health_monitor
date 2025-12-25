from app import create_app
from models import db, WaterSample, DiseaseAlert
from notifications import check_water_quality_alerts, check_disease_alerts, create_notification

def create_test_data():
    app = create_app()
    
    with app.app_context():
        db.create_all()
        
        print("Creating test data that will trigger alerts...")
        
        # Critical pH sample
        sample1 = WaterSample(
            location='Test Well - Critical pH',
            state='Test State',
            district='Test District',
            ph=5.2,  # Will trigger alert
            turbidity=2.0,
            bacterial_count=100,
            temperature=25.0,
            contamination_level='Safe'
        )
        db.session.add(sample1)
        db.session.commit()
        check_water_quality_alerts(sample1)
        print("Added critical pH sample")
        
        # High turbidity sample
        sample2 = WaterSample(
            location='Test Well - High Turbidity',
            state='Test State',
            district='Test District',
            ph=7.2,
            turbidity=6.8,  # Will trigger alert
            bacterial_count=200,
            temperature=26.0,
            contamination_level='Moderate'
        )
        db.session.add(sample2)
        db.session.commit()
        check_water_quality_alerts(sample2)
        print("Added high turbidity sample")
        
        # High risk contamination
        sample3 = WaterSample(
            location='Test Well - Contaminated',
            state='Test State',
            district='Test District',
            ph=7.0,
            turbidity=3.0,
            bacterial_count=500,
            temperature=28.0,
            contamination_level='High Risk'  # Will trigger alert
        )
        db.session.add(sample3)
        db.session.commit()
        check_water_quality_alerts(sample3)
        print("Added contaminated sample")
        
        # Disease outbreak
        alert1 = DiseaseAlert(
            disease='Test Cholera Outbreak',
            cases=25,
            risk_level='Critical',  # Will trigger alert
            location='Test Area',
            state='Test State',
            district='Test District'
        )
        db.session.add(alert1)
        db.session.commit()
        check_disease_alerts(alert1)
        print("Added disease outbreak")
        
        # Manual notifications
        create_notification(
            title="System Test",
            message="This is a test notification",
            notification_type="system"
        )
        print("Added system notification")
        
        print("Test data created successfully!")
        print("Expected: 4-5 notifications generated")

if __name__ == '__main__':
    create_test_data()