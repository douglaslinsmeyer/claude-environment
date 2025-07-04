# Mobile App Development Configuration

This Claude configuration is optimized for mobile application development projects.

## Project Context

### Tech Stack
- **iOS**: Swift 5.5+, SwiftUI/UIKit, Xcode 14+
- **Android**: Kotlin 1.8+, Jetpack Compose/XML, Android Studio
- **Cross-Platform**: React Native / Flutter
- **Backend**: Firebase / AWS Amplify / Custom REST API
- **State Management**: Redux (RN) / Riverpod (Flutter) / Combine (iOS)
- **Testing**: XCTest, Espresso, Jest, Detox
- **CI/CD**: Fastlane, GitHub Actions, Bitrise

### Project Structure (React Native)
```
src/
├── components/        # Reusable UI components
│   ├── common/       # Generic components
│   └── screens/      # Screen-specific components
├── screens/          # Screen components
├── navigation/       # Navigation configuration
├── services/         # API and external services
├── store/           # State management
├── utils/           # Helper functions
├── hooks/           # Custom hooks
├── assets/          # Images, fonts, etc.
└── constants/       # App constants
```

### Project Structure (Flutter)
```
lib/
├── models/          # Data models
├── views/           # UI screens
├── widgets/         # Reusable widgets
├── controllers/     # Business logic
├── services/        # API and services
├── utils/           # Utilities
├── constants/       # Constants
└── main.dart        # Entry point
```

## Platform-Specific Guidelines

### iOS Development (Swift)
```swift
// MARK: - SwiftUI View Example
struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            List(viewModel.items) { item in
                ItemRow(item: item)
                    .onTapGesture {
                        viewModel.selectItem(item)
                    }
            }
            .navigationTitle("Items")
            .navigationBarItems(
                trailing: Button(action: viewModel.refresh) {
                    Image(systemName: "arrow.clockwise")
                }
            )
            .onAppear {
                viewModel.loadItems()
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

// MARK: - ViewModel
@MainActor
class ContentViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let service = ItemService()
    
    func loadItems() async {
        do {
            items = try await service.fetchItems()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
```

### Android Development (Kotlin)
```kotlin
// Jetpack Compose Example
@Composable
fun ItemsScreen(
    viewModel: ItemsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Items") },
                actions = {
                    IconButton(onClick = { viewModel.refresh() }) {
                        Icon(Icons.Default.Refresh, contentDescription = "Refresh")
                    }
                }
            )
        }
    ) { paddingValues ->
        when (val state = uiState) {
            is UiState.Loading -> {
                Box(modifier = Modifier.fillMaxSize()) {
                    CircularProgressIndicator(
                        modifier = Modifier.align(Alignment.Center)
                    )
                }
            }
            is UiState.Success -> {
                LazyColumn(
                    modifier = Modifier.padding(paddingValues),
                    contentPadding = PaddingValues(16.dp)
                ) {
                    items(state.items) { item ->
                        ItemCard(
                            item = item,
                            onClick = { viewModel.selectItem(item) }
                        )
                    }
                }
            }
            is UiState.Error -> {
                ErrorMessage(
                    message = state.message,
                    onRetry = { viewModel.retry() }
                )
            }
        }
    }
}

// ViewModel
@HiltViewModel
class ItemsViewModel @Inject constructor(
    private val repository: ItemRepository
) : ViewModel() {
    
    private val _uiState = MutableStateFlow<UiState>(UiState.Loading)
    val uiState: StateFlow<UiState> = _uiState.asStateFlow()
    
    init {
        loadItems()
    }
    
    private fun loadItems() {
        viewModelScope.launch {
            repository.getItems()
                .catch { _uiState.value = UiState.Error(it.message ?: "Error") }
                .collect { items ->
                    _uiState.value = UiState.Success(items)
                }
        }
    }
}
```

### React Native Example
```typescript
// Component with TypeScript
interface ItemListProps {
  navigation: NavigationProp<RootStackParamList>;
}

export const ItemList: React.FC<ItemListProps> = ({ navigation }) => {
  const dispatch = useAppDispatch();
  const { items, loading, error } = useAppSelector(state => state.items);
  const [refreshing, setRefreshing] = useState(false);

  useEffect(() => {
    dispatch(fetchItems());
  }, [dispatch]);

  const handleRefresh = useCallback(async () => {
    setRefreshing(true);
    await dispatch(fetchItems());
    setRefreshing(false);
  }, [dispatch]);

  const renderItem = useCallback(({ item }: { item: Item }) => (
    <TouchableOpacity
      style={styles.itemContainer}
      onPress={() => navigation.navigate('ItemDetail', { itemId: item.id })}
      activeOpacity={0.7}
    >
      <ItemCard item={item} />
    </TouchableOpacity>
  ), [navigation]);

  if (loading && !refreshing) {
    return <LoadingView />;
  }

  if (error) {
    return <ErrorView error={error} onRetry={() => dispatch(fetchItems())} />;
  }

  return (
    <SafeAreaView style={styles.container}>
      <FlatList
        data={items}
        renderItem={renderItem}
        keyExtractor={item => item.id}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={handleRefresh} />
        }
        contentContainerStyle={styles.listContent}
      />
    </SafeAreaView>
  );
};
```

## Claude Instructions

### When Building UI
1. Follow platform-specific design guidelines (HIG for iOS, Material Design for Android)
2. Ensure responsive layouts for different screen sizes
3. Implement proper loading and error states
4. Handle keyboard appearance/dismissal
5. Support both light and dark themes
6. Implement accessibility features
7. Optimize for performance (lazy loading, virtualization)
8. Handle device orientation changes

### When Managing State
1. Keep state as local as possible
2. Use proper state management patterns
3. Implement optimistic updates
4. Cache data appropriately
5. Handle offline scenarios
6. Sync state with backend
7. Implement proper data persistence
8. Clean up resources on unmount

### When Handling Navigation
1. Use type-safe navigation
2. Handle deep linking
3. Implement proper back button behavior
4. Save and restore navigation state
5. Handle authentication flows
6. Implement tab navigation properly
7. Use modal presentations appropriately
8. Handle push notifications navigation

## Performance Optimization

### React Native Performance
```typescript
// Optimize list rendering
const ItemList = memo(({ items }: Props) => {
  const renderItem = useCallback(({ item }) => (
    <ItemRow item={item} />
  ), []);

  const keyExtractor = useCallback((item) => item.id, []);

  const getItemLayout = useCallback((data, index) => ({
    length: ITEM_HEIGHT,
    offset: ITEM_HEIGHT * index,
    index,
  }), []);

  return (
    <FlatList
      data={items}
      renderItem={renderItem}
      keyExtractor={keyExtractor}
      getItemLayout={getItemLayout}
      removeClippedSubviews
      maxToRenderPerBatch={10}
      windowSize={10}
      initialNumToRender={10}
    />
  );
});

// Optimize images
import FastImage from 'react-native-fast-image';

<FastImage
  source={{ uri: imageUrl, priority: FastImage.priority.normal }}
  style={styles.image}
  resizeMode={FastImage.resizeMode.cover}
/>
```

### iOS Performance
```swift
// Optimize table/collection views
class ItemCell: UITableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset cell state
        imageView?.image = nil
        textLabel?.text = nil
    }
}

// Image caching
import SDWebImage

imageView.sd_setImage(with: URL(string: imageURL),
                      placeholderImage: UIImage(named: "placeholder"))

// Async operations
Task {
    do {
        let items = try await fetchItems()
        await MainActor.run {
            self.items = items
            self.tableView.reloadData()
        }
    } catch {
        // Handle error
    }
}
```

## Testing Standards

### Unit Tests
```swift
// iOS XCTest Example
class ItemViewModelTests: XCTestCase {
    var viewModel: ItemViewModel!
    var mockService: MockItemService!
    
    override func setUp() {
        super.setUp()
        mockService = MockItemService()
        viewModel = ItemViewModel(service: mockService)
    }
    
    func testLoadItemsSuccess() async {
        // Given
        let expectedItems = [Item.mock()]
        mockService.itemsToReturn = expectedItems
        
        // When
        await viewModel.loadItems()
        
        // Then
        XCTAssertEqual(viewModel.items, expectedItems)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
}
```

### UI Tests
```typescript
// React Native Detox Example
describe('Item List Screen', () => {
  beforeAll(async () => {
    await device.launchApp();
  });

  it('should show item list', async () => {
    await expect(element(by.id('itemList'))).toBeVisible();
    await expect(element(by.text('Item 1'))).toBeVisible();
  });

  it('should refresh list on pull', async () => {
    await element(by.id('itemList')).swipe('down', 'slow');
    await waitFor(element(by.id('refreshControl')))
      .toBeVisible()
      .withTimeout(2000);
  });

  it('should navigate to detail on tap', async () => {
    await element(by.text('Item 1')).tap();
    await expect(element(by.id('itemDetailScreen'))).toBeVisible();
  });
});
```

## Accessibility Guidelines

### iOS Accessibility
```swift
// VoiceOver support
button.accessibilityLabel = "Refresh items"
button.accessibilityHint = "Double tap to refresh the list of items"
button.accessibilityTraits = .button

// Dynamic Type support
label.font = .preferredFont(forTextStyle: .body)
label.adjustsFontForContentSizeCategory = true

// Voice Control
button.accessibilityUserInputLabels = ["Refresh", "Reload", "Update"]
```

### React Native Accessibility
```typescript
<TouchableOpacity
  accessible={true}
  accessibilityLabel="Refresh items"
  accessibilityHint="Double tap to refresh the list"
  accessibilityRole="button"
  onPress={handleRefresh}
>
  <Icon name="refresh" />
</TouchableOpacity>

<Text
  style={styles.heading}
  accessibilityRole="header"
  allowFontScaling={true}
>
  Items
</Text>
```

## Security Best Practices

### Secure Storage
```typescript
// React Native
import * as Keychain from 'react-native-keychain';

// Store sensitive data
await Keychain.setInternetCredentials(
  'myapp.com',
  username,
  password
);

// Retrieve sensitive data
const credentials = await Keychain.getInternetCredentials('myapp.com');
```

### API Security
```swift
// iOS
class APIClient {
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "X-API-Key": ProcessInfo.processInfo.environment["API_KEY"] ?? ""
        ]
        self.session = URLSession(configuration: config)
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = endpoint.method.rawValue
        
        // Add auth token
        if let token = KeychainService.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

## App Store Guidelines

### iOS App Store
- Follow Apple's Human Interface Guidelines
- Implement proper privacy nutrition labels
- Handle App Tracking Transparency
- Support the latest iOS versions
- Provide proper app descriptions
- Include all required screenshots
- Handle in-app purchases properly
- Implement proper push notification handling

### Google Play Store
- Follow Material Design guidelines
- Implement proper permissions handling
- Support target API level requirements
- Handle app bundles (AAB format)
- Provide proper store listing
- Include feature graphics
- Implement proper billing
- Handle background restrictions

## Development Workflow

### Build & Release
```bash
# iOS Release
fastlane ios release

# Android Release
fastlane android release

# React Native
# Update version
npm version patch

# Build iOS
cd ios && pod install
npx react-native run-ios --configuration Release

# Build Android
cd android && ./gradlew assembleRelease
```

### Code Quality
- Use ESLint/SwiftLint/Ktlint
- Run unit tests before commits
- Check for memory leaks
- Profile performance regularly
- Monitor crash reports
- Track app analytics
- Review security regularly
- Update dependencies monthly

---

*This configuration is optimized for mobile app development. Adjust based on your specific platform and requirements.*