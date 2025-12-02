# Authentication System Documentation

## Overview

The EasyEats backend now includes a complete user authentication system with the following features:
- User registration with email and password
- Secure password hashing using Node.js crypto module
- User login
- Profile management (storing nutrition goals, age, sex, calorie targets)

## Database

User data is stored in a JSON file at `Backend/data/users.json`. This file is automatically created when the server starts.

### User Schema
```json
{
  "id": 1,
  "email": "user@example.com",
  "password_hash": "salt:hash",
  "created_at": "2025-11-24T03:20:00.000Z",
  "goal": "Losing weight",
  "age": 25,
  "sex": "Male",
  "calories": 2000,
  "updated_at": "2025-11-24T03:25:00.000Z"
}
```

## Starting the Server

```bash
cd Backend
node server.js
```

The server will start on `http://localhost:3000`

## API Endpoints

### 1. Register New User
**POST** `/api/auth/register`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (Success - 201):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "message": "User registered successfully"
}
```

**Response (Error - 400):**
```json
{
  "error": "Email already exists"
}
```

### 2. Login User
**POST** `/api/auth/login`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (Success - 200):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "goal": "Losing weight",
  "age": 25,
  "sex": "Male",
  "calories": 2000,
  "message": "Login successful"
}
```

**Response (Error - 401):**
```json
{
  "error": "Invalid email or password"
}
```

### 3. Update User Profile
**PUT** `/api/user/:userId/profile`

**Request Body:**
```json
{
  "goal": "Losing weight",
  "age": 25,
  "sex": "Male",
  "calories": 2000
}
```

**Response (Success - 200):**
```json
{
  "message": "Profile updated successfully",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "goal": "Losing weight",
    "age": 25,
    "sex": "Male",
    "calories": 2000
  }
}
```

### 4. Get User Profile
**GET** `/api/user/:userId/profile`

**Response (Success - 200):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "goal": "Losing weight",
  "age": 25,
  "sex": "Male",
  "calories": 2000,
  "created_at": "2025-11-24T03:20:00.000Z"
}
```

## Testing with cURL

### Register a new user:
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### Login:
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### Update profile:
```bash
curl -X PUT http://localhost:3000/api/user/1/profile \
  -H "Content-Type: application/json" \
  -d '{"goal":"Losing weight","age":25,"sex":"Male","calories":2000}'
```

### Get profile:
```bash
curl http://localhost:3000/api/user/1/profile
```

## Flutter Integration

The Flutter app includes an `AuthService` class at `Frontend/flutter_easyeats/lib/services/auth_service.dart` that handles all API communication.

### Important Configuration

If testing on a physical device, update the `baseUrl` in `auth_service.dart`:
```dart
// Replace localhost with your computer's IP address
static const String baseUrl = 'http://192.168.1.XXX:3000/api';
```

For Android emulator, use:
```dart
static const String baseUrl = 'http://10.0.2.2:3000/api';
```

## Security Features

- Passwords are hashed using PBKDF2 with SHA-512
- Each password uses a unique random salt
- Passwords are never stored in plain text
- Email validation on registration
- Minimum password length of 6 characters

## File Structure

```
Backend/
├── server.js           # Main server with all API endpoints
├── auth.js            # Authentication logic and user management
├── data/
│   └── users.json     # User database (auto-created)
└── AUTH_README.md     # This file
```

## Error Handling

The API returns appropriate HTTP status codes:
- `200` - Success (login, get profile, update profile)
- `201` - Created (registration)
- `400` - Bad Request (validation errors, duplicate email)
- `401` - Unauthorized (invalid credentials)
- `404` - Not Found (user doesn't exist)

## Next Steps

To enhance the authentication system, consider:
1. Adding JWT tokens for session management
2. Implementing password reset functionality
3. Adding email verification
4. Migrating from JSON file to a proper database (PostgreSQL, MongoDB)
5. Adding rate limiting to prevent brute force attacks
