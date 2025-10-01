# User Flow Document

## Overview
This document maps out how users navigate through the Water Intake Reminder app.

## Flow Types

**Key Navigation Principles:**
- Minimize taps to log water
- Lock screen functionality is primary feature
- Settings are secondary but accessible
- Progress visualization is always visible
- Backend intelligence learns silently (completely invisible to users)

### 5. Backend Intelligence (Invisible to Users)
```
User Logs Water → Backend Records Pattern → Learns Habits → Optimizes Experience
```
**What Backend Learns:**
- **Volume patterns:** User's preferred amounts (starts with 200ml, 225ml, 300ml, 350ml)
- **Custom amounts:** Learns from user's custom inputs to suggest better defaults
- **Active hours:** User drinks between 7AM-10PM
- **Frequency needs:** 2250ml ÷ average volume = optimal reminder count
- **Optimal timing:** Distribute reminders across active hours

**Backend Optimization:**
- **Volume recommendations:** AI adjusts the 4 volume buttons based on user habits
- **Reminder timing:** Adjusts intervals based on user's drinking patterns
- **Personalized options:** Lock screen buttons become user-specific over time
- **Completely invisible:** User never sees AI working, just better experience

### 1. First-Time User (Onboarding)
```
App Launch → Permission Request (Notifications) → Main Dashboard
```
**Details:**
- Request notification permissions only
- Default goal: 76oz/2250ml (no setup required)
- Land directly on main progress screen

### 2. Daily Usage Flow
```
Open App → View Progress → Tap Volume Button → Updated Progress
```
**Single screen with:**
- Progress circle with water-themed gradient
- Four volume buttons: 200ml, 225ml, 300ml, 350ml (bigger, water-themed)
- Custom amount input with unit selection (ml/oz)
- Animated water background with floating bubbles
- That's it

### 3. Lock Screen Notification Flow
```
Notification Appears → User Sees Volume Buttons → Tap Volume → Water Logged → Notification Dismissed
```
**Trigger:** Backend optimized timing (starts at 30 minutes)
**Options:** 200ml, 225ml, 300ml, 350ml (AI will personalize these)
**Result:** Progress updates without unlocking phone

### 3.1. Daily Completion Reminder (8PM)
```
8PM Check → If Goal Not Met → Send Completion Reminder → Partner Gets Custom Message
```
**Default Message:** "You still have {volume}ml left to reach your daily goal. Keep hydrating!"
**Partner Message:** "My love, you still have {volume}ml of water you need to drink. Please complete it while knowing that I love you."
**Customizable:** Users can edit both messages in settings

### 4. Settings & Sharing Flow
```
Main Screen → Settings Icon → Minimal Settings
```
**Simple settings:**
- Daily goal adjustment
- Share with support person (simple toggle)
- Customize completion reminder messages
- That's it