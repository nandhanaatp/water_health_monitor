#!/usr/bin/env python3
"""
Quick test script to generate notification test data
Run this to populate your database with test data that triggers alerts
"""

import sys
import os

# Add the backend directory to Python path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from test_notifications import create_test_data

if __name__ == '__main__':
    print("🚀 Starting notification test data generation...")
    create_test_data()
    print("\n✅ Done! Start your Flask server and check the notifications.")
    print("\n📱 In your Flutter app:")
    print("1. Login as admin (admin/admin123)")
    print("2. Click on 'Test Alerts' card")
    print("3. Try different test buttons")
    print("4. Check 'Notifications' to see alerts")