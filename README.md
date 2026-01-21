# QuoteVault

A full-featured quote discovery and collection iOS app built with **SwiftUI**, **Supabase**, and **SwiftData**.

![QuoteVault](https://img.shields.io/badge/Platform-iOS%2017%2B-blue)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-orange)
![Supabase](https://img.shields.io/badge/Backend-Supabase-green)

## Features

### 🔐 Authentication & User Accounts
- Email/password sign up and login
- Password reset flow via email
- Session persistence (stay logged in)
- User profile management

### 📚 Quote Browsing & Discovery
- Home feed with Quote of the Day
- Browse quotes by 9 categories (Motivation, Love, Success, Wisdom, Humor, Life, Business, Creativity, Growth)
- Search quotes by keyword or author
- Pull-to-refresh functionality
- Infinite scroll pagination
- Beautiful loading and empty states

### ❤️ Favorites & Collections
- Save quotes to favorites (heart button)
- View all favorited quotes
- Create custom collections
- Add/remove quotes from collections
- Cloud sync - favorites persist across devices

### 📅 Daily Quote & Notifications
- Quote of the Day prominently displayed
- Daily quote changes automatically
- Local push notifications for daily inspiration
- Customizable notification time

### 🎨 Sharing & Export
- Share quote as text via system share sheet
- Generate beautiful quote cards
- 4 card styles: Ocean, Clean, Nature, Noir
- Save card to photos or share directly

### ⚙️ Personalization & Settings
- Dark/Light/Auto mode toggle
- 5 accent color options
- Font size adjustment
- All settings sync to user profile

## Tech Stack

- **Frontend**: SwiftUI
- **Backend**: Supabase (Auth + PostgreSQL)
- **Local Storage**: SwiftData
- **Architecture**: MVVM
- **Minimum iOS**: 17.0

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/QuoteVault.git
cd QuoteVault
```

### 2. Open in Xcode

```bash
open QuoteVault.xcodeproj
```

### 3. Supabase Configuration

The app is pre-configured with a Supabase backend. If you want to use your own:

1. Create a new project at [supabase.com](https://supabase.com)
2. Run the database migrations (see `supabase/migrations/`)
3. Update `Config/Constants.swift` with your credentials:

```swift
enum Supabase {
    static let url = "YOUR_SUPABASE_URL"
    static let anonKey = "YOUR_ANON_KEY"
}
```

### 4. Build & Run

1. Select your target device/simulator
2. Press `Cmd + R` to build and run

## Project Structure

```
QuoteVault/
├── Config/           # App configuration and theming
├── Models/           # Data models (Codable + SwiftData)
├── Services/         # API services (Supabase, Notifications)
├── ViewModels/       # View models (MVVM)
├── Views/            # SwiftUI views organized by feature
│   ├── App/          # Root navigation
│   ├── Auth/         # Authentication flows
│   ├── Home/         # Home screen
│   ├── Discover/     # Browse/search quotes
│   ├── Saved/        # Favorites & Collections
│   ├── QuoteDetail/  # Quote details & share cards
│   └── Settings/     # User settings
├── Components/       # Reusable UI components
└── Extensions/       # Swift extensions
```

## Database Schema

The app uses the following Supabase tables:

- **categories** - Quote categories (Motivation, Love, etc.)
- **quotes** - 108+ quotes with author, category, likes
- **profiles** - User preferences and settings
- **favorites** - User's favorite quotes
- **collections** - Custom quote collections
- **collection_quotes** - Many-to-many junction table

## AI Tools Used

This project was built leveraging AI coding assistants:

- **Gemini/Antigravity** - Primary development assistant
- Comprehensive prompt engineering for SwiftUI best practices
- AI-assisted database schema design
- Automated code generation and refactoring

## Screenshots

| Welcome | Login | Home | Discover |
|---------|-------|------|----------|
| Welcome screen with onboarding | Email/password login | Quote of the Day + categories | Browse & search quotes |

| Collections | Quote Detail | Share Card | Settings |
|-------------|--------------|------------|----------|
| User collections grid | Full quote view | Create shareable cards | Profile & preferences |

## Known Limitations

- Widget extension not yet implemented
- Social auth (Google/Apple) not included
- Profile photo upload not implemented
- Comments feature UI-only

## Future Enhancements

- [ ] iOS Widget with Quote of the Day
- [ ] Apple Watch app
- [ ] Share extension
- [ ] iCloud sync for offline support
- [ ] Quote submission by users

## License

MIT License - Feel free to use this project for learning or building upon.

## Contact

For questions about this assignment, reach out to: lazyme2305@gmail.com
