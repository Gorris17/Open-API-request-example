# iTunes Search – iOS Technical Assignment

iOS/macOS SwiftUI app that searches music via the iTunes Search API, built as an Alten technical assignment.

---

## Public API

**iTunes Search API** — no key or authentication required.

| Parameter | Value |
|---|---|
| Base URL | `https://itunes.apple.com/search` |
| `entity` | `song` |
| `limit` | `25` |
| `term` | user query |

Example: `https://itunes.apple.com/search?term=queen&entity=song&limit=25`

Each result exposes: track name, artist, album, artwork URL, genre, release year, and price.

---

## How to run

**Requirements:** Xcode 16+, iOS 18+ Simulator or device.

1. Open `API-Request-example/API-Request-example.xcodeproj`
2. Select the **API-Request-example** scheme and an iOS Simulator
3. `⌘R` — build and run
4. `⌘U` — run the unit tests

---

## Screens

### Search
- Search field triggers a live query against the iTunes API
- Results displayed in a scrollable list with artwork, title, artist and album
- While the field is empty, a **Recently Viewed** section shows previously opened tracks (persisted locally via SwiftData), tappable to navigate directly to their detail without a new network request
- Swipe-to-delete on recent entries

### Detail
- Displays full track info: song, artist, album, genre, release year, price
- Artwork is upscaled to 300×300 for display
- On appear, the track is saved to (or deduplicated in) the recently viewed list

---

## Architecture

Clean Architecture with three explicit layers. The dependency arrow always points inward — Presentation and Data both depend on Domain; Domain depends on nothing.

```
API-Request-example/
├── Domain/
│   ├── Entities/           Track.swift
│   ├── Repositories/       TrackRepositoryProtocol.swift   (protocol)
│   └── UseCases/           SearchTracksService.swift
├── Data/
│   ├── Network/            APIService.swift, ITunesEndpoint.swift
│   ├── POSOs/              TrackPOSO.swift, SearchResponsePOSO.swift
│   ├── Cache/              SearchCache.swift, CacheManager.swift
│   ├── Persistence/        RecentTrackEntity.swift          (SwiftData)
│   └── Repositories/       TrackRepository.swift            (impl)
├── Presentation/
│   ├── Search/             SearchView.swift, SearchViewModel.swift
│   └── Detail/             DetailView.swift
└── DI/
    ├── ServiceFactory.swift   (composition root)
    └── AppLogger.swift        (OSLog facade)
```

**Dependency injection** is constructor-based throughout. `ServiceFactory` is the single composition root — every service is a `static let` (lazily initialised on first access), making all dependencies swappable for tests.

**`@Observable` + `@State`** — ViewModels use the `Observation` framework instead of `ObservableObject`. Views bind with `@State private var viewModel = …`.

**POSO suffix** — all `Decodable` network DTOs are named `*POSO` (Plain Old Swift Object). The `toDomain()` mapping lives in an extension on the POSO, keeping the Domain entity free of any data-layer concerns.

---

## Key technical decisions

### Cancellation
`SearchViewModel` holds a `Task` reference. Every call to `search()` cancels the previous task before spawning a new one. Swift structured concurrency propagates that cancellation into `URLSession.data(for:)`, aborting the in-flight network request automatically — no manual state cleanup needed.

### Debounce
A 300 ms `Task.sleep` sits at the start of each search task. If the user types another character within that window, the task is cancelled during the sleep and exits silently. Only the task that survives the full 300 ms proceeds to the network. This reuses the existing cancellation mechanism — no timers or extra state required.

### In-memory cache
`SearchCache` is a dictionary keyed by the lowercased query string with a configurable TTL (default 3 minutes). `TrackRepository` checks the cache first; on a miss it fetches from the API and stores the result. An expired entry is evicted on the next read. `CacheManager` runs a periodic background sweep (every 5 minutes) to purge all expired entries proactively.

The cache lives in RAM only — it is intentionally not persisted to disk, so a fresh launch always reflects the latest API data.

### Persistence — recently viewed tracks
`RecentTrackEntity` is a SwiftData `@Model` that stores the **full** track detail (all fields, including artwork URL, genre, release year and price) when the user opens the detail screen. On revisit, the existing record's `viewedAt` timestamp is bumped rather than inserting a duplicate (deduplication by `trackId`). `SearchView` reads recent tracks via `@Query` and displays them while the search field is empty, navigating to `DetailView` without any network call.

### Logging
`AppLogger` is a thin facade over OSLog. It is the **only** file that imports `OSLog` — all other files call `AppLogger.debug/info/error(_:_:)` with plain Swift strings. Four categories are available: `network`, `cache`, `persistence`, `search`. Filter by the app's bundle identifier subsystem in Console.app or Instruments.

---

## Tests

| Suite | Layer | What it covers |
|---|---|---|
| `SearchCacheTests` | Data | Empty cache, hit, case-insensitivity, TTL expiry, overwrite |
| `SearchTracksUseCaseTests` | Domain | Empty/blank query guard, whitespace trimming, delegation, error propagation |
| `RecentTrackEntityTests` | Data | Full field storage, nil handling (artwork, price), `viewedAt` timestamp, `toDomain()` round-trip |
| `SearchViewModelTests` | Presentation | Debounce suppresses intermediate keystrokes, search fires after window, blank query skipped |

All Domain and Data tests use a `MockTrackRepository` so they have zero network or framework dependencies.
