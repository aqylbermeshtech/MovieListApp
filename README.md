# MovieListApp

MovieListApp is an iOS application that allows users to browse trending movies, view detailed information, and explore related content using The Movie Database (TMDb) API.

<div align="center">
  <video src="https://github.com/user-attachments/assets/7db2906a-34fa-4262-97bc-6d1617b28575" controls width="300"></video>
</div>





## Features

- Browse trending movies (daily)
- View detailed movie information
- Watch trailers (via YouTube integration)
- Display movie posters and images
- Smooth and responsive UI
- Networking with real API data
- Clean and scalable architecture

## Tech Stack

- Swift
- UIKit (programmatic UI)
- MVVM
- URLSession
- JSONDecoder (.convertFromSnakeCase)
- TMDb API

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** architecture:

- **Model** — represents API data
- **ViewModel** — handles business logic and data transformation
- **View** — displays UI and binds to ViewModel

This approach improves code readability, scalability, and testability.

## API Integration

Data is fetched from **TMDb API**:

- Trending movies endpoint:
- Movie videos (trailers):
Images are loaded using:

https://image.tmdb.org/t/p/w185


## Main Screens

### Movie List Screen

Displays trending movies in a scrollable list.

### Movie Details Screen

Shows detailed information about a selected movie:
- Title
- Description
- Poster
- Trailer

## What I Learned

While building this project, I improved my skills in:

- Working with REST APIs
- Networking using URLSession
- Parsing JSON with JSONDecoder
- Using `.convertFromSnakeCase`
- Building scalable apps with MVVM
- Creating smooth UIKit interfaces programmatically
- Handling asynchronous data loading

## Installation

1. Clone the repository:

```bash
git clone https://github.com/iblamenooo/MovieListApp.git
```

2. Add the two local-only files that are intentionally not committed (they hold secrets):

   - **`Config/Secrets.xcconfig`** — create this file next to `MovieListApp.xcodeproj` (i.e. a
     sibling of the `MovieListApp` and `MovieListApp.xcodeproj` folders, *not* inside either of
     them) by copying `MovieListApp/Config/Secrets.xcconfig.example` and filling in your own
     [TMDb](https://www.themoviedb.org/settings/api) and
     [Guardian](https://open-platform.theguardian.com/access/) API keys.
   - **`GoogleService-Info.plist`** — download this from the
     [Firebase console](https://console.firebase.google.com/) for the `movielistapp-13a53`
     project and place it in `MovieListApp/`.

3. Open `MovieListApp.xcodeproj` in Xcode and run.
