# UI Components

## Reusable Components

### 1. Volume Button
**Usage:** Main screen, lock screen notifications
**Specs:**
- Size: 120pt x 80pt (bigger for better touch)
- Corner radius: 20pt
- Background: Blue to cyan gradient with water theme
- Text: SF Pro Text, Bold, 22pt (volume), Medium, 14pt (unit)
- Shadow: Blue shadow for depth
- Border: White semi-transparent overlay

### 2. Progress Circle
**Usage:** Main screen, support person view
**Specs:**
- Diameter: 200pt
- Stroke width: 12pt
- Background: Light gray (#F2F2F7)
- Progress: Blue (#007AFF)
- Text: SF Pro Display, Bold, 32pt (percentage), Regular, 17pt (volume)

### 3. Settings Row
**Usage:** Settings screen
**Specs:**
- Height: 44pt minimum
- Background: White (#FFFFFF)
- Separator: Light gray (#C6C6C8)
- Text: SF Pro Text, Regular, 17pt
- Chevron: Gray (#8E8E93)

### 4. Notification Card
**Usage:** Lock screen notifications
**Specs:**
- Corner radius: 16pt
- Background: White with blur effect
- Shadow: 0pt 4pt 16pt rgba(0,0,0,0.1)
- Padding: 16pt

### 5. Custom Amount Input
**Usage:** Modal sheet for custom water logging
**Specs:**
- TextField: Rounded border style, 50pt height
- Unit Picker: Segmented control (ml/oz)
- Log Button: Full width, 50pt height, blue background
- Auto-conversion: oz to ml (1 oz = 29.5735 ml)

### 6. Water Background
**Usage:** Main screen background
**Specs:**
- Gradient: Blue to cyan with low opacity
- Animated bubbles: 6 circles, random sizes (20-40pt)
- Animation: Linear movement from bottom to top
- Duration: 3-6 seconds with staggered delays

## Component States

### Volume Button States
- **Default:** Blue gradient background, white text
- **Pressed:** Slightly scaled down with animation
- **Disabled:** 50% opacity

### Custom Input States
- **Empty:** Log button disabled
- **Valid input:** Log button enabled, blue background
- **Invalid input:** Log button disabled, gray background

### Progress Circle States
- **Loading:** Animated pulse
- **Complete:** Green color (#34C759)
- **Behind goal:** Orange color (#FF9500)

## Accessibility
- All buttons: Minimum 44pt touch target
- Text contrast: WCAG AA compliant
- VoiceOver labels for all interactive elements
- Dynamic Type support