import requests
import json

# Test data
test_data = {
    "ph": 7.2,
    "hardness": 120,
    "solids": 30000,
    "chloramines": 3.5,
    "sulfate": 250,
    "conductivity": 400,
    "organic_carbon": 10,
    "trihalomethanes": 60,
    "turbidity": 3.0
}

try:
    response = requests.post('http://127.0.0.1:5000/predict', json=test_data)
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
except Exception as e:
    print(f"Error: {e}")