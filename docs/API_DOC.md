# Good Night API Documentation

## Overview

Good Night API is a sleep tracking service with social features. Users can track their sleep patterns, follow other users, and view sleep timelines from people they follow.

**Base URL**: `/v1`

## Authentication

Most endpoints require authentication via JWT token in the Authorization header:

```
Authorization: Bearer <jwt_token>
```

**Exception**: Only the session creation endpoint (`POST /v1/sessions`) does not require authentication.

## Data Models

### User
- `id`: Unique identifier
- `name`: Username (unique)
- `created_at`, `updated_at`: Timestamps

### Sleep Record
- `id`: Unique identifier
- `user_id`: Foreign key to user
- `slept_at`: When user went to sleep
- `woke_up_at`: When user woke up (null for active sleep)
- `duration_in_minutes`: Sleep duration (calculated when woke up)
- `created_at`, `updated_at`: Timestamps

### Follow
- `id`: Unique identifier
- `follower_id`: User who is following
- `followee_id`: User being followed
- `created_at`, `updated_at`: Timestamps

## API Endpoints

### Sessions
- `POST /v1/sessions` - Create session (login)
  - **Body**: `{ "name": "username" }`
  - **Response**: `{ "token": "<jwt_token>" }`
  - **Status**: 200 OK

### Sleep Records
- `GET /v1/sleep_records` - List current user's sleep records
  - **Response**: Paginated list of sleep records
  - **Status**: 200 OK

- `POST /v1/sleep_records/clock_in` - Start a new sleep session
  - **Response**: Created sleep record with `slept_at` timestamp
  - **Status**: 201 Created

- `POST /v1/sleep_records/clock_out` - End current sleep session
  - **Response**: Updated sleep record with `woke_up_at` and calculated duration
  - **Status**: 200 OK

### Sleep Timelines
- `GET /v1/sleep_timelines` - View sleep records from followed users
  - **Response**: Paginated sleep records from users you follow, ordered by sleep duration
  - **Status**: 200 OK

### Following System
- `POST /v1/users/follow` - Follow another user
  - **Body**: `{ "followee_id": <user_id> }`
  - **Response**: Follow relationship details
  - **Status**: 201 Created

- `DELETE /v1/users/unfollow` - Unfollow a user
  - **Body**: `{ "followee_id": <user_id> }`
  - **Response**: No content
  - **Status**: 204 No Content

## Response Format

### Success Responses
All successful responses include data wrapped in a root key:
- Sleep records: `{ "sleep_records": [...] }`
- Single sleep record: `{ "sleep_record": {...} }`
- Sleep timeline: `{ "sleep_timeline": [...] }`
- Follow: `{ "follow": {...} }`
- Sessions: `{ "token": "..." }`

### Paginated Responses
Include metadata:
```json
{
  "sleep_records": [...],
  "meta": {
    "pagination": {
      "count": 10,
      "page": 1,
      "next": "/v1/sleep_records?page=2"
    }
  }
}
```

### Error Responses
```json
{
  "error": {
    "code": "error_type",
    "message": "Description of the error",
    "detail": ["Additional error details"]
  }
}
```

## Error Codes

- `400` - Bad Request: Malformed request body
- `401` - Unauthorized: Invalid or missing authentication
- `404` - Not Found: Resource not found
- `422` - Unprocessable Content: Resource validation failed
- `500` - Internal Server Error: Unexpected server error

## Usage Flow

1. **Authentication**: Create a session by sending username to get JWT token
2. **Sleep Tracking**: Use clock-in/clock-out endpoints to track sleep sessions
3. **Social Features**: Follow other users to see their sleep patterns
4. **Timeline**: View sleep records from followed users, ordered by sleep duration
