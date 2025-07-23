# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Fingle is a fitness-focused social media Flutter application with video feed, comments, reactions, and activity tracking features. The app targets iOS, Android, Web, macOS, Windows, and Linux platforms.

## Build and Development Commands

### Essential Commands
- **Install dependencies**: `flutter pub get`
- **Run the app**: `flutter run`
- **Run on specific device**: `flutter run -d [device_id]` (use `flutter devices` to list)
- **Build release versions
- **:
  - Android APK: `flutter build apk`
  - Android App Bundle: `flutter build appbundle`
  - iOS: `flutter build ios`
  - Web: `flutter build web`

### Code Quality
- **Analyze code**: `flutter analyze`
- **Format code**: `flutter format .`
- **Run tests**: `flutter test`
- **Run specific test**: `flutter test test/[test_file.dart]`

## Architecture

The app follows a clean architecture pattern with Provider for state management:

```
lib/
├── core/           # App-wide constants, theme (AppColors, AppTheme), utilities
├── models/         # Data models (UserModel, VideoModel, CommentModel, ReactionModel)
├── providers/      # State management (AppProvider, VideoFeedProvider, CommentsProvider)
├── screens/        # Feature screens with dedicated widget subdirectories
│   ├── fingle/     # Main video feed with player, comments, reactions
│   ├── home/       # Home landing screen
│   ├── activity/   # Fitness tracking features
│   ├── profile/    # User profiles with tabs, stats, headers
│   └── search/     # Content discovery
├── services/       # Business logic (ScreenTimeoutService)
├── navigation/     # MainNavigation routing
└── widgets/        # Shared UI components
```

## Key Technical Details

### State Management
- Uses Provider pattern with ChangeNotifier
- Main providers: AppProvider (global state), VideoFeedProvider (video feed logic), CommentsProvider (comments system)

### Video Features
- Video player implementation in `screens/fingle/widgets/video_player.dart`
- Comments system with sorting in `screens/fingle/widgets/comments_section.dart`
- Reactions system being developed (reaction_button.dart, reaction_picker.dart)
- Screen brightness and wakelock management for video playback

### Testing
- Test files go in `/test/` directory
- Use `flutter_test` SDK for unit and widget tests
- Linting configured via `analysis_options.yaml` using `flutter_lints: ^6.0.0`

### Current Development
- Active development on `dev` branch
- Recently implemented: Comments with improved UI, comment sorting
- In progress: Reactions feature, recommendation system

## Development Workflow

1. Always run `flutter analyze` before committing to catch lint issues
2. Format code with `flutter format .` to maintain consistent style
3. Test on multiple platforms when making UI changes
4. The app uses Material Design - follow Material guidelines for new UI components
5. State changes should go through appropriate providers, not direct widget state

Always make sure to maintain top-notch production grade code quuality without over-engineering things.