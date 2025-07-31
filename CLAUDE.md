# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Fingle is an active lifestyle-focused social media Flutter application with video feed, comments, reactions, and activity tracking features. The app targets iOS, Android, Web, macOS, Windows, and Linux platforms.

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

Always make sure to maintain top-notch production grade code quality without over-engineering things.

## Backend Development

### Backend Todo Management
- **Backend Tasks**: All backend development tasks are tracked in `backend_todos.md`
- **Progress Tracking**: Use the TodoWrite tool to mark backend tasks as completed
- **Todo Management Commands**:
  - Mark task complete: Update status to "completed" with completion timestamp
  - Add reference links: Include commit hashes and file references for completed tasks
  - Track dependencies: Note any blocking issues or required prerequisites

### Backend Architecture (Supabase + MCP)
- **Technology Stack**: Supabase + MCP + TypeScript + Flutter + Real-time APIs
- **Database**: Supabase PostgreSQL with automatic API generation
- **Authentication**: Built-in Supabase Auth with JWT tokens
- **Media Storage**: Supabase Storage with automatic optimization
- **Real-time**: Native Supabase real-time subscriptions via WebSockets
- **Development**: AI-assisted with Claude Code MCP integration

### Backend Development Workflow
1. **MCP-Assisted Development**: Use Claude Code MCP integration for natural language database operations
2. **Phase-based Development**: Follow backend_todos.md phases (MCP Setup → Content Schema → Interactions → Search → Flutter Integration)
3. **Real-time First**: Set up Supabase real-time subscriptions for live features
4. **Task Completion**: Always update backend_todos.md when completing tasks
5. **API Integration**: Ensure all Supabase APIs return data matching Flutter model structures
6. **Testing**: Use built-in Supabase tools for testing before Flutter integration

### Backend Integration with Frontend
- **Data Models**: Backend APIs must return data matching Flutter models exactly
- **Provider Integration**: Update Flutter providers to use real APIs instead of mock data
- **Error Handling**: Implement proper error states in both backend and frontend
- **Loading States**: Coordinate backend response times with frontend loading indicators

### Supabase MCP Setup Instructions
1. **Create Supabase Project**: Go to supabase.com, create account and new project named "fingle-backend"
2. **Get Credentials**: Note project reference ID, generate personal access token from Settings → Access Tokens
3. **Configure MCP**: Run `claude mcp add supabase -s local -e SUPABASE_ACCESS_TOKEN=your_token -- npx -y @supabase/mcp-server-supabase@latest --read-only --project-ref=your_ref`
4. **Test Connection**: Verify MCP tools work with "list tables" or "show project info"

### Current Backend Status
- **Phase**: Ready for MCP Setup (Phase 0)
- **Next Steps**: Begin Phase 0 (Supabase MCP Integration Setup)
- **Dependencies**: Supabase account, personal access token
- **Estimated Timeline**: 6-8 weeks for full backend implementation (50% faster with MCP)