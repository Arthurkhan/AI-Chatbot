# Design System

**Last Updated**: 2025-07-10
**Status**: Approved
**Author**: App Project Architect

## Overview

The AI Chatbot design system ensures consistent, accessible, and beautiful user interfaces across all screens and platforms.

## Design Principles

1. **Simplicity First**: Clean, uncluttered interfaces
2. **Accessibility**: WCAG 2.1 AA compliant
3. **Consistency**: Unified experience across features
4. **Delight**: Smooth animations and micro-interactions
5. **Familiarity**: Follow platform conventions

## Color Palette

### Light Theme

```dart
// Primary Colors
Primary: #2196F3 (Blue)
PrimaryLight: #64B5F6
PrimaryDark: #1976D2

// Secondary Colors
Secondary: #FF4081 (Pink)
SecondaryLight: #FF80AB
SecondaryDark: #F50057

// Neutral Colors
Background: #FFFFFF
Surface: #F5F5F5
Error: #F44336
OnPrimary: #FFFFFF
OnSecondary: #FFFFFF
OnBackground: #000000
OnSurface: #000000
OnError: #FFFFFF

// Text Colors
TextPrimary: rgba(0, 0, 0, 0.87)
TextSecondary: rgba(0, 0, 0, 0.60)
TextDisabled: rgba(0, 0, 0, 0.38)
```

### Dark Theme

```dart
// Primary Colors
Primary: #90CAF9 (Light Blue)
PrimaryLight: #BBDEFB
PrimaryDark: #42A5F5

// Secondary Colors
Secondary: #FF80AB (Light Pink)
SecondaryLight: #FFB2DD
SecondaryDark: #FF4081

// Neutral Colors
Background: #121212
Surface: #1E1E1E
Error: #CF6679
OnPrimary: #000000
OnSecondary: #000000
OnBackground: #FFFFFF
OnSurface: #FFFFFF
OnError: #000000

// Text Colors
TextPrimary: rgba(255, 255, 255, 0.87)
TextSecondary: rgba(255, 255, 255, 0.60)
TextDisabled: rgba(255, 255, 255, 0.38)
```

## Typography

### Font Family
- **Primary**: Inter (Google Fonts)
- **Monospace**: JetBrains Mono (for code)
- **Fallback**: System default

### Type Scale

```dart
// Display
Display1: 57px, Light (300)
Display2: 45px, Regular (400)

// Headlines
H1: 32px, Bold (700)
H2: 28px, Bold (700)
H3: 24px, Medium (500)
H4: 20px, Medium (500)
H5: 18px, Medium (500)
H6: 16px, Medium (500)

// Body
Body1: 16px, Regular (400)
Body2: 14px, Regular (400)

// Supporting
Subtitle1: 16px, Medium (500)
Subtitle2: 14px, Medium (500)
Caption: 12px, Regular (400)
Overline: 10px, Medium (500), UPPERCASE

// Buttons
Button: 14px, Medium (500), UPPERCASE
```

## Spacing System

8px grid system:

```dart
const spacing = {
  xs: 4,   // 0.5x
  sm: 8,   // 1x
  md: 16,  // 2x
  lg: 24,  // 3x
  xl: 32,  // 4x
  xxl: 48, // 6x
  xxxl: 64 // 8x
};
```

## Components

### Buttons

```dart
// Primary Button
ElevatedButton(
  height: 48px
  borderRadius: 24px
  elevation: 2
  padding: horizontal 24px
)

// Secondary Button
OutlinedButton(
  height: 48px
  borderRadius: 24px
  borderWidth: 2px
  padding: horizontal 24px
)

// Text Button
TextButton(
  height: 48px
  padding: horizontal 16px
)

// Icon Button
IconButton(
  size: 48px
  splashRadius: 24px
)
```

### Cards

```dart
Card(
  borderRadius: 16px
  elevation: 2
  padding: 16px
  margin: 8px
)

// Personality Card
PersonalityCard(
  height: 80px
  borderRadius: 16px
  padding: 16px
  avatar: 48px circle
)
```

### Chat Bubbles

```dart
// User Message
UserBubble(
  maxWidth: 75% of screen
  borderRadius: 18px
  borderBottomRight: 4px
  padding: 12px 16px
  background: Primary color
)

// AI Message
AIBubble(
  maxWidth: 75% of screen
  borderRadius: 18px
  borderBottomLeft: 4px
  padding: 12px 16px
  background: Surface color
)
```

### Input Fields

```dart
TextField(
  height: 56px
  borderRadius: 28px
  fillColor: Surface
  contentPadding: horizontal 24px
  fontSize: 16px
)
```

## Icons

### Icon Set
- **Primary**: Material Icons Rounded
- **Custom**: Custom icon font for special icons
- **Size**: 24px default, 20px small, 28px large

### Commonly Used Icons
```
chat_bubble_rounded
person_rounded
settings_rounded
add_rounded
edit_rounded
delete_rounded
archive_rounded
mic_rounded
attach_file_rounded
send_rounded
```

## Animations

### Duration
```dart
const animationDuration = {
  instant: 0ms,
  fast: 200ms,
  normal: 300ms,
  slow: 500ms,
  verySlow: 1000ms
};
```

### Curves
```dart
const animationCurve = {
  standard: Curves.easeInOut,
  decelerate: Curves.easeOut,
  accelerate: Curves.easeIn,
  sharp: Curves.linear
};
```

### Common Animations
1. **Page Transitions**: Slide + Fade
2. **List Items**: Staggered fade in
3. **Button Press**: Scale 0.95
4. **Loading**: Shimmer effect
5. **Message Appear**: Slide up + Fade

## Elevation & Shadows

```dart
const elevation = {
  none: 0,
  low: 2,
  medium: 4,
  high: 8,
  veryHigh: 16
};
```

## Responsive Breakpoints

```dart
const breakpoints = {
  mobile: 0,     // 0-599px
  tablet: 600,   // 600-1023px
  desktop: 1024, // 1024px+
};
```

## Accessibility

### Color Contrast
- Text on background: 4.5:1 minimum
- Large text: 3:1 minimum
- Interactive elements: 3:1 minimum

### Touch Targets
- Minimum size: 48x48px
- Spacing between: 8px minimum

### Semantic Labels
- All interactive elements have labels
- Images have descriptions
- Screen reader optimized

## Platform Adaptations

### Android
- Material Design 3 guidelines
- System navigation gestures
- Dynamic theming support

### iOS (Future)
- Cupertino widgets where appropriate
- iOS-specific gestures
- Platform-specific animations

## Design Tokens

```dart
abstract class DesignTokens {
  // Spacing
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 16;
  static const double space4 = 24;
  static const double space5 = 32;
  static const double space6 = 48;
  
  // Border Radius
  static const double radiusSmall = 8;
  static const double radiusMedium = 16;
  static const double radiusLarge = 24;
  static const double radiusXLarge = 32;
  
  // Animation
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
}
```