# UI Mockups

## Design Philosophy
- **Ultra-simple:** One main screen, minimal interactions
- **Clean:** Lots of white space, clear typography
- **Intuitive:** No tutorials needed
- **Intelligent:** Backend learns user patterns invisibly

## Screen Designs

### 1. Main Progress Screen (Primary Screen)

```
┌─────────────────────────────────┐
│  ☰                    ⚙️        │  <- Menu & Settings
│                                 │
│         💧 HydroTrack           │  <- App name
│                                 │
│            ╭─────╮              │
│           ╱       ╲             │
│          │   65%   │            │  <- Progress circle
│          │ 1462ml  │            │     Shows current/goal
│           ╲ 2250ml ╱            │
│            ╰─────╯              │
│                                 │
│     ┌─────┐ ┌─────┐             │
│     │200ml│ │225ml│             │  <- Volume buttons
│     └─────┘ └─────┘             │     (Top row)
│                                 │
│     ┌─────┐ ┌─────┐             │
│     │300ml│ │350ml│             │  <- Volume buttons
│     └─────┘ └─────┘             │     (Bottom row)
│                                 │
│     ┌───────────────┐           │
│     │ Custom Amount │           │  <- Custom input
│     └───────────────┘           │
│                                 │
│                                 │
│                                 │
│                                 │
└─────────────────────────────────┘
```

**Key Elements:**
- **Progress Circle:** Large, visual, shows percentage and ml
- **Four Buttons:** 200ml, 225ml, 300ml, 350ml (AI will personalize later)
- **Custom Amount:** User can input any volume with unit selection (ml/oz)
- **Water Theme:** Blue gradient background with floating bubble animations
- **Clean Footer:** No distracting elements
- **Clean Layout:** Lots of white space

### 2. Settings Screen (Minimal)

```
┌─────────────────────────────────┐
│  ← Back              Settings   │
│                                 │
│                                 │
│  Daily Goal                     │
│  ┌─────────────────────────────┐ │
│  │        2250ml               │ │  <- Adjustable goal
│  └─────────────────────────────┘ │
│                                 │
│                                 │
│  Share Progress                 │
│  ┌─────────────────────────────┐ │
│  │ Connect Support Person  ○   │ │  <- Toggle switch
│  └─────────────────────────────┘ │
│                                 │
│  Reminder Messages              │
│  ┌─────────────────────────────┐ │
│  │ Customize 8PM Messages     › │ │  <- Message settings
│  └─────────────────────────────┘ │
│                                 │
│                                 │
│                                 │
└─────────────────────────────────┘
```

**Key Elements:**
- **Three settings:** Goal, Sharing, Message customization
- **Simple controls:** Number input, toggle, text editing

### 3. Lock Screen Notification (Regular)

```
┌─────────────────────────────────┐
│                                 │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ │
│  │200ml│ │225ml│ │300ml│ │350ml│ │  <- Quick log buttons only
│  └─────┘ └─────┘ └─────┘ └─────┘ │
│                                 │
└─────────────────────────────────┘
```

### 3.1. 8PM Completion Reminder

```
┌─────────────────────────────────┐
│  💧 Daily Goal Reminder          │
│                                 │
│  You still have 450ml left to   │
│  reach your daily goal.          │  <- Default message
│  Keep hydrating!                 │
│                                 │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ │
│  │200ml│ │225ml│ │300ml│ │350ml│ │
│  └─────┘ └─────┘ └─────┘ └─────┘ │
│                                 │
└─────────────────────────────────┘
```

**Partner receives custom message:**
"My love, you still have 450ml of water you need to drink. Please complete it while knowing that I love you."

**Key Elements:**
**Regular Notification:**
- **Volume buttons only:** No text, no distractions
- **Minimal design:** Just the essential logging options
- **AI will optimize:** Backend learns and adjusts these volumes per user

**8PM Completion Reminder:**
- **Motivational message:** Encourages goal completion
- **Partner notification:** Custom loving message sent automatically
- **Same logging options:** Consistent user experience

### 4. Support Person View (Shared Progress)

```
┌─────────────────────────────────┐
│  ← Back         Sarah's Water   │
│                                 │
│                                 │
│            ╭─────╮              │
│           ╱       ╲             │
│          │   78%   │            │  <- Partner's progress
│          │ 1755ml  │            │
│           ╲ 2250ml ╱            │
│            ╰─────╯              │
│                                 │
│  Today's Pattern                │
│  ┌─────────────────────────────┐ │
│  │ 🕐 9:00 AM - 240ml          │ │  <- Drinking timeline
│  │ 🕐 11:30 AM - 355ml         │ │
│  │ 🕐 2:15 PM - 475ml          │ │
│  │ 🕐 4:45 PM - 240ml          │ │
│  │ 🕐 6:30 PM - 355ml          │ │
│  └─────────────────────────────┘ │
│                                 │
│                                 │
│                                 │
└─────────────────────────────────┘
```

**Key Elements:**
- **Partner's progress:** Same visual style
- **Timeline view:** Shows drinking patterns
- **Clean interface:** Focus on progress and patterns

## Design Specifications

### Colors
- **Primary:** Blue (#007AFF) - iOS standard
- **Success:** Green (#34C759) - progress completion
- **Background:** White (#FFFFFF)
- **Text:** Black (#000000) and Gray (#8E8E93)

### Typography
- **Headers:** SF Pro Display, Bold, 24pt
- **Body:** SF Pro Text, Regular, 17pt
- **Buttons:** SF Pro Text, Medium, 17pt

### Spacing
- **Margins:** 20pt from screen edges
- **Button spacing:** 16pt between elements
- **Progress circle:** 200pt diameter

## iOS Design Compliance
- Follows Apple Human Interface Guidelines
- Uses SF Pro font family
- Standard iOS button styles
- Native navigation patterns
- Accessibility support built-in