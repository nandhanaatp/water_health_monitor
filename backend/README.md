# Water Health Monitor Backend

## Setup
1. Install Python dependencies:
   ```
   pip install -r requirements.txt
   ```

2. Run the server:
   ```
   python app.py
   ```

## API Endpoints
- `POST /api/water` - Add water intake (body: {"amount": 250})
- `GET /api/water` - Get all water intake records
- `GET /api/water/today` - Get today's total intake

Server runs on http://localhost:5000