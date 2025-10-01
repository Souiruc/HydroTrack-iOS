# Data Models & Architecture

## Core Data Models

### WaterEntry
```
- id: UUID
- volume: Int (ml)
- timestamp: Date
- userId: UUID
```

### User
```
- id: UUID
- dailyGoal: Int (ml, default: 2250)
- createdAt: Date
- partnerId: UUID? (optional)
```

### UserSettings
```
- userId: UUID
- defaultMessage: String
- partnerMessage: String
- notificationsEnabled: Bool
- volumePreferences: [Int] (AI-learned volumes)
```

### BedrockRecommendations
```
- userId: UUID
- suggestedVolumes: [Int] (Bedrock's recommendations)
- optimalTiming: Int (minutes between reminders)
- confidence: Float (Bedrock's confidence score)
- lastUpdated: Date
```

## Data Flow

### Logging Water
```
User taps volume → Create WaterEntry → Update daily progress → Sync to backend → Update AI learning
```

### Bedrock Learning Process
```
New WaterEntry → Lambda triggers Bedrock → Analyze patterns → Update volume preferences → Store recommendations
```

### Partner Sharing
```
User enables sharing → Create connection → Sync WaterEntry data → Send 8PM notifications to partner
```

## Backend API Endpoints

### Core Endpoints
- `POST /water-entries` - Log water intake
- `GET /water-entries/today` - Get today's entries
- `PUT /users/goal` - Update daily goal
- `POST /users/connect` - Connect with partner

### Bedrock Integration
- **Background process:** Lambda triggers Bedrock after water entries
- **Pattern analysis:** Bedrock analyzes user drinking patterns
- **Volume optimization:** Returns personalized volume suggestions
- **No direct endpoints:** AI works behind the scenes

### Notification Endpoints
- `POST /notifications/schedule` - Schedule personalized reminders
- `POST /notifications/partner` - Send partner notification

## Local Storage (Core Data)

### Offline Support
- Store entries locally first
- Sync to backend when online
- Handle conflicts with timestamp priority

### Performance
- Fetch only current day by default
- Lazy loading for historical data
- Background Bedrock analysis for personalization

## Security & Privacy

### Data Protection
- All personal data encrypted at rest
- Partner connections require mutual consent
- AI learning data anonymized for processing

### API Security
- JWT tokens for authentication
- HTTPS only for all communications
- Rate limiting on all endpoints