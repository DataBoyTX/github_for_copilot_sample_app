from flask import Flask, request, jsonify, send_from_directory
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from datetime import datetime
import os

app = Flask(__name__, static_folder='../frontend', static_url_path='')
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:////data/submissions.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
CORS(app)

# Database model
class Submission(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_name = db.Column(db.String(100), nullable=False)
    user_age = db.Column(db.Integer, nullable=False)
    event_date = db.Column(db.Date, nullable=False)
    submitted_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'user_name': self.user_name,
            'user_age': self.user_age,
            'event_date': self.event_date.strftime('%Y-%m-%d'),
            'submitted_at': self.submitted_at.strftime('%Y-%m-%d %H:%M:%S')
        }

# Create tables
with app.app_context():
    db.create_all()

# Serve frontend
@app.route('/')
def index():
    return send_from_directory('../frontend', 'index.html')

# API endpoints
@app.route('/api/submit', methods=['POST'])
def submit():
    try:
        data = request.get_json()
        
        # Validate input
        if not data.get('user_name') or not data.get('user_age') or not data.get('event_date'):
            return jsonify({'error': 'Missing required fields'}), 400
        
        try:
            age = int(data['user_age'])
            if age < 0 or age > 150:
                return jsonify({'error': 'Age must be between 0 and 150'}), 400
        except ValueError:
            return jsonify({'error': 'Age must be a valid number'}), 400
        
        # Parse date
        try:
            event_date = datetime.strptime(data['event_date'], '%Y-%m-%d').date()
        except ValueError:
            return jsonify({'error': 'Invalid date format. Use YYYY-MM-DD'}), 400
        
        # Create submission
        submission = Submission(
            user_name=data['user_name'].strip(),
            user_age=age,
            event_date=event_date
        )
        db.session.add(submission)
        db.session.commit()
        
        return jsonify({'message': 'Submission successful', 'submission': submission.to_dict()}), 201
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@app.route('/api/submissions', methods=['GET'])
def get_submissions():
    try:
        submissions = Submission.query.order_by(Submission.submitted_at.desc()).all()
        return jsonify([submission.to_dict() for submission in submissions]), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/submission/<int:id>', methods=['GET'])
def get_submission(id):
    try:
        submission = Submission.query.get(id)
        if not submission:
            return jsonify({'error': 'Submission not found'}), 404
        return jsonify(submission.to_dict()), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
