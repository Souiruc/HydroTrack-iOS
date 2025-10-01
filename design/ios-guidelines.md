# iOS Design Guidelines Compliance

## Apple Human Interface Guidelines Adherence

### Navigation
- **Tab Bar:** Not used (single screen focus)
- **Navigation Bar:** Minimal, back button only
- **Modal Presentation:** Settings as modal sheet

### Typography
- **System Font:** SF Pro family exclusively
- **Dynamic Type:** Support all accessibility sizes
- **Hierarchy:** Clear size and weight differences

### Color System
- **System Colors:** Blue (#007AFF), Green (#34C759)
- **Semantic Colors:** Label, secondaryLabel, systemBackground
- **Dark Mode:** Automatic color adaptation

### Layout
- **Safe Areas:** Respect all device safe areas
- **Margins:** 20pt standard, 16pt compact
- **Spacing:** 8pt, 16pt, 24pt increments

### Interactions
- **Touch Targets:** Minimum 44pt x 44pt
- **Haptic Feedback:** Light impact on button press
- **Animation:** Standard iOS spring animations

### Notifications
- **Rich Notifications:** Interactive buttons
- **Critical Alerts:** For 8PM reminders (if permitted)
- **Notification Categories:** Custom water logging category

### Accessibility
- **VoiceOver:** Full support with meaningful labels
- **Dynamic Type:** Text scales appropriately
- **Reduce Motion:** Respect animation preferences
- **High Contrast:** Support increased contrast modes

### Privacy
- **Permissions:** Request notifications with clear explanation
- **Data Sharing:** Explicit consent for partner sharing
- **Local Storage:** Core Data for offline functionality

## Device Support
- **iPhone:** iOS 15.0+
- **Screen Sizes:** All current iPhone sizes
- **Orientation:** Portrait only (simpler UX)

## App Store Guidelines
- **Metadata:** Clear app description and screenshots
- **Content:** Health and fitness category
- **Permissions:** Justified notification requests