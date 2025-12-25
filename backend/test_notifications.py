from app import create_app
from models import db, WaterSample, DiseaseAlert
from notifications import check_water_quality_alerts, check_disease_alerts, create_notification
from datetime import datetime

def create_test_data():
    """Create test data that will trigger notifications"""
    app = create_app()
    
    with app.app_context():
        # Clear existing data
        db.drop_all()
        db.create_all()
        
        print("🧪 Creating test data that will trigger alerts...")
        
        # Test water samples that will trigger alerts
        test_samples = [
            # Critical pH - too low
            {
                'location': 'Test Well A',
                'state': 'Maharashtra',
                'district': 'Mumbai',
                'ph': 5.2,  # Will trigger alert (< 6.0)
                'turbidity': 2.0,
                'bacterial_count': 100,
                'temperature': 25.0,
                'contamination_level': 'Safe'
            },
            # Critical pH - too high
            {
                'location': 'Test Well B',
                'state': 'Karnataka',
                'district': 'Bangalore',
                'ph': 9.1,  # Will trigger alert (> 8.5)
                'turbidity': 1.5,
                'bacterial_count': 50,
                'temperature': 24.0,
                'contamination_level': 'Safe'
            },
            # High turbidity
            {
                'location': 'Test Well C',
                'state': 'Tamil Nadu',
                'district': 'Chennai',
                'ph': 7.2,
                'turbidity': 6.8,  # Will trigger alert (> 5.0)
                'bacterial_count': 200,
                'temperature': 26.0,
                'contamination_level': 'Moderate'
            },
            # High risk contamination
            {
                'location': 'Test Well D',
                'state': 'Gujarat',
                'district': 'Ahmedabad',
                'ph': 7.0,
                'turbidity': 3.0,
                'bacterial_count': 500,
                'temperature': 28.0,
                'contamination_level': 'High Risk'  # Will trigger alert
            },
            # Multiple issues
            {
                'location': 'Test Well E',
                'state': 'Rajasthan',
                'district': 'Jaipur',
                'ph': 5.8,  # Will trigger alert
                'turbidity': 7.2,  # Will trigger alert
                'bacterial_count': 800,
                'temperature': 30.0,
                'contamination_level': 'High Risk'  # Will trigger alert
            }
        ]
        
        # Add water samples and check for alerts
        for sample_data in test_samples:
            sample = WaterSample(**sample_data)
            db.session.add(sample)
            db.session.commit()
            
            # Check for alerts
            alerts = check_water_quality_alerts(sample)
            print(f"✅ Added sample at {sample.location} - Generated {len(alerts)} alerts")
        
        # Test disease alerts that will trigger notifications
        test_diseases = [
            {
                'disease': 'Cholera',
                'cases': 25,
                'risk_level': 'High',  # Will trigger alert
                'location': 'Test Area A',
                'state': 'West Bengal',
                'district': 'Kolkata'
            },
            {
                'disease': 'Dengue',
                'cases': 50,
                'risk_level': 'Critical',  # Will trigger alert
                'location': 'Test Area B',
                'state': 'Delhi',
                'district': 'New Delhi'
            },
            {
                'disease': 'Typhoid',
                'cases': 8,
                'risk_level': 'Medium',  # Will NOT trigger alert
                'location': 'Test Area C',
                'state': 'Punjab',
                'district': 'Chandigarh'
            }
        ]
        
        # Add disease alerts and check for notifications
        for disease_data in test_diseases:
            alert = DiseaseAlert(**disease_data)
            db.session.add(alert)
            db.session.commit()
            
            # Check for alerts
            alerts = check_disease_alerts(alert)
            print(f"✅ Added disease alert for {alert.disease} - Generated {len(alerts)} alerts")
        
        # Add some manual notifications for testing
        create_notification(
            title="System Maintenance",
            message="Scheduled maintenance will occur tonight from 2-4 AM",
            notification_type="system"
        )
        
        create_notification(
            title="New Feature Available",
            message="Real-time notifications are now active!",
            notification_type="system"
        )
        
        print("\n🎯 Test data created successfully!")
        print("Expected notifications:")
        print("- 3 pH alerts (Wells A, B, E)")
        print("- 2 turbidity alerts (Wells C, E)")
        print("- 2 contamination alerts (Wells D, E)")
        print("- 2 disease outbreak alerts (Cholera, Dengue)")
        print("- 2 system notifications")
        print("Total: ~9 notifications")

if __name__ == '__main__':
    create_test_data()