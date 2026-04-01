# iTunes Search – iOS Technical Assignment

iOS/macOS app that searches music via the iTunes Search API, built as an Alten technical assignment.

## Public API

**iTunes Search API** — `https://itunes.apple.com/search`

No API key or authentication required. A search query returns tracks with: name, artist, album, artwork, genre, release year, and price.

Example request: `https://itunes.apple.com/search?term=queen&entity=song&limit=25`

## How to run

Requirements: **Xcode 16+**, iOS 18+ Simulator or device.

1. Open `API-Request-example/API-Request-example.xcodeproj`.
2. Select the **API-Request-example** scheme and an iOS Simulator.
3. Press **⌘R** to build and run.
4. Press **⌘U** to run the unit tests.

## Screens

| Screen | Description |
|---|---|
| **Search** | Search field + results list. When the field is empty, shows recently viewed tracks (persisted via SwiftData). |
| **Detail** | Displays song, artist, album, genre, release year and price. Saves the track to the recently viewed list on appear. |

## Architecture

Clean Architecture split into three explicit layers. Dependency direction is always inward: Presentation → Domain ← Data.

```
API-Request-example/
├── Domain/          # Pure Swift — entities, repository protocols, use cases
├── Data/            # Network (APIService + ITunesEndpoint), DTOs (*POSO),
│                    # SearchCache, TrackRepositoryImpl, RecentTrackEntity (SwiftData)
├── Presentation/    # SearchView + SearchViewModel, DetailView
└── DI/              # ServiceFactory — static singletons, wires the full graph
```

Dependency injection is constructor-based throughout. `ServiceFactory` is the single composition root — each service is a `static let` (lazily initialised on first access), making every dependency swappable for tests.

## Key decisions

### Cancellation
`SearchViewModel` stores a `Task` reference. Every new search call invokes `searchTask?.cancel()` before spawning a new task. Swift's structured concurrency propagates cancellation down into `URLSession.data(for:)`, so in-flight network requests are cancelled automatically.

### Cache
`SearchCache` is an in-memory dictionary keyed by the lowercased query string, with a configurable TTL (default 3 minutes). `TrackRepositoryImpl` checks the cache before touching the network and stores the result on a miss. An expired entry is evicted on next read.

### Persistence
`RecentTrackEntity` is a SwiftData `@Model` that records tracks opened in the detail view. `SearchView` reads them with `@Query` and displays a *Recently Viewed* list while the search field is empty.

### DTOs
All `Decodable` network objects are suffixed `POSO` (*Plain Old Swift Object*) to make the boundary between network data and domain entities explicit at a glance. The mapping (`toDomain()`) lives in an extension on the POSO itself, keeping the Domain entity free of any data-layer concerns.

## Tests

| Test suite | What it covers |
|---|---|
| `SearchCacheTests` | Empty cache, cache hit, case-insensitivity, TTL expiry, overwrite |
| `SearchTracksUseCaseTests` | Blank/empty query guard, whitespace trimming, delegation, error propagation |

Repositories are mocked via protocol (`TrackRepository`) so Domain tests have zero network or framework dependencies.
