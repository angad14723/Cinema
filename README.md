# 🎬 Complete Movies Database iOS Application
I've successfully implemented a comprehensive Movies Database iOS application

### Architecture & Code Quality:
* MVVM Architecture: Clean separation of concerns
* Protocol-Oriented Design: Service protocols for testability
* Error Handling: Comprehensive error handling throughout
* Async/Await: Modern Swift concurrency

### Home Tab with Trending and Now Playing Movies
**HomeView** : Displays both trending and now playing movies in separate sections.

**Pagination** : Automatically loads more movies as user scrolls (20 movies per page).

**Pull-to-refresh** : Users can refresh the data

**Loading states** : Shows loading indicators and error messages

### Movie Details View with Navigation
**MovieDetailsView**: Comprehensive movie details with backdrop image, poster, ratings, release date, and overview,

**Navigation** : Tap any movie to view detailed information.

**Bookmarking** : Users can bookmark/unbookmark movies directly from details view.

**Sharing** : Share movies with custom deep links.

### Bookmarking System with Core Data
**Core Data Integration** : Movies are saved locally using Core Data.

**Bookmarks Tab** : Dedicated tab to view all bookmarked movies.

**Persistent Storage** : Bookmarks survive app restarts.

**Remove Bookmarks** : Users can remove bookmarks from the bookmarks list.


### Offline Support with Local Database
**Core Data Manager** : Handles all local storage operations.

**Cache System** : API responses are cached for 24 hours.

**Offline Functionality** : App works without internet using cached data.

**Cache Expiry** : Automatic cleanup of expired cache entries.

### Search Tab with Real-time Search
**Debounced Search** : Network calls are made 0.5 seconds after user stops typing.

**Real-time Results** : Search results update as user types.

**Pagination** : Load more search results as user scrolls.

**Clear Search** : Easy way to clear search and start over



<img width="367" height="755" alt="Screenshot 2025-08-25 at 11 45 52 AM" src="https://github.com/user-attachments/assets/22e20cbe-8280-4660-8546-16cbbbb1841b" />
<img width="367" height="763" alt="Screenshot 2025-08-25 at 11 46 03 AM" src="https://github.com/user-attachments/assets/a2a4f08a-8879-4016-a23e-99efa040c11e" />
<img width="366" height="761" alt="Screenshot 2025-08-25 at 11 46 14 AM" src="https://github.com/user-attachments/assets/6afa33a8-8290-439a-9b6f-ea2f477bf4f5" />
<img width="361" height="755" alt="Screenshot 2025-08-25 at 12 03 14 PM" src="https://github.com/user-attachments/assets/429d4373-da48-475b-8ea3-ffc2999541cc" />

