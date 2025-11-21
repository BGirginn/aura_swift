# Aura Color Finder - Teknik Proje Planı

**Kaynak Doküman:** aura_color.md  
**Platform:** iOS (SwiftUI + MVVM)  
**Tarih:** Kasım 2024  
**Durum:** Planlama Aşaması

---

## 1. PROJE GENEL BAKIŞ

### 1.1 Ürün Tanımı
Aura Color Finder, kullanıcının fotoğrafından aura renklerini analiz eden, kültürel adaptasyon ile yorumlar sunan iOS uygulamasıdır.

### 1.2 Hedef Kitle
- Spiritüel/astroloji içerik tüketicileri
- Meditasyon ve farkındalık uygulama kullanıcıları
- Sosyal medya paylaşım odaklı genç kullanıcılar
- Eğlenceli kişilik analizi arayanlar

### 1.3 Temel Özellikler
- Kamera ile real-time aura taraması
- Vision framework ile yüz tespiti
- HSV + k-means ile dominant renk çıkarımı (1-3 renk)
- Çok ülkeli aura yorumları (TR/US/DE/UK/FR)
- Geçmiş tarama kayıtları
- Animasyonlu aura renk halkaları
- Paylaşılabilir sonuç kartları
- Premium: sınırsız tarama, detaylı yorumlar, trend grafiği

---

## 2. TEKNİK MİMARİ

### 2.1 Sistem Bileşenleri
```
┌─────────────────────────────────────────────┐
│         iOS App (SwiftUI + MVVM)            │
├─────────────────────────────────────────────┤
│  - Views (UI Layer)                         │
│  - ViewModels (Business Logic)              │
│  - Services (Core Functions)                │
│  - Models (Data Structures)                 │
└─────────────────────────────────────────────┘
            ↓
┌─────────────────────────────────────────────┐
│         AuraEngine (On-Device)              │
│  - Vision Framework (Face Detection)        │
│  - CoreImage (Image Processing)             │
│  - Custom HSV + k-means Algorithm           │
│  - Optional: CoreML Model (Phase 3)         │
└─────────────────────────────────────────────┘
            ↓
┌─────────────────────────────────────────────┐
│      Local Storage (Core Data)              │
│  - Scan History                             │
│  - User Preferences                         │
│  - Cached Localizations                     │
└─────────────────────────────────────────────┘
            ↓
┌─────────────────────────────────────────────┐
│     Optional: Backend (Firebase)            │
│  - Remote Config (Aura Descriptions)        │
│  - Analytics (Firebase/Amplitude)           │
│  - IAP Validation (StoreKit Server)         │
│  - Cloud Sync (Firestore - Phase 2+)        │
└─────────────────────────────────────────────┘
```

### 2.2 MVVM Akış Diagramı
```
User Action
    ↓
[View] ← observes ← [ViewModel (ObservableObject)]
                        ↓ uses
                    [Service Layer]
                        ↓ manipulates
                    [Model/Data]
```

---

## 3. PROJE KLASÖR YAPISI

```
AuraColorFinder/
├── App/
│   ├── AuraColorFinderApp.swift          # Main entry point
│   ├── AppDelegate.swift                 # App lifecycle
│   └── ContentView.swift                 # Root coordinator view
│
├── Core/
│   ├── Extensions/
│   │   ├── Color+Hex.swift
│   │   ├── View+Extensions.swift
│   │   └── Image+Processing.swift
│   ├── Utilities/
│   │   ├── Constants.swift
│   │   ├── AppCoordinator.swift
│   │   └── ErrorHandler.swift
│   └── Helpers/
│       ├── HapticManager.swift
│       └── PermissionManager.swift
│
├── Models/
│   ├── AuraColor.swift
│   │   - id: String
│   │   - name: String
│   │   - hueRange: ClosedRange<Double>
│   │   - saturationMin: Double
│   │   - brightnessMin: Double
│   │   - hexValue: String
│   │   - localizedDescriptions: [String: LocalizedDescription]
│   │
│   ├── AuraResult.swift
│   │   - id: UUID
│   │   - timestamp: Date
│   │   - primaryColor: AuraColor
│   │   - secondaryColor: AuraColor?
│   │   - tertiaryColor: AuraColor?
│   │   - dominancePercentages: [Double]
│   │   - countryCode: String
│   │   - imageData: Data?
│   │
│   ├── ScanHistory.swift (Core Data Entity)
│   │   - id: UUID
│   │   - timestamp: Date
│   │   - primaryColorId: String
│   │   - secondaryColorId: String?
│   │   - tertiaryColorId: String?
│   │   - dominancePercentages: Data (JSON)
│   │   - countryCode: String
│   │   - imageData: Data?
│   │   - isFavorite: Bool
│   │
│   └── UserPreferences.swift
│       - selectedCountryCode: String
│       - selectedLanguage: String
│       - isPremiumUser: Bool
│       - dailyScanCount: Int
│       - lastScanDate: Date
│
├── ViewModels/
│   ├── OnboardingViewModel.swift
│   │   - currentPage: Int
│   │   - completeOnboarding()
│   │
│   ├── CameraViewModel.swift
│   │   - permissionStatus: AVAuthorizationStatus
│   │   - isProcessing: Bool
│   │   - capturedImage: UIImage?
│   │   - detectedAuraResult: AuraResult?
│   │   - errorMessage: String?
│   │   - requestCameraPermission()
│   │   - processImage(UIImage)
│   │   - canScanToday() -> Bool
│   │   - incrementDailyCount()
│   │   - getRemainingScans() -> Int
│   │
│   ├── ResultViewModel.swift
│   │   - auraResult: AuraResult
│   │   - showFullDescription: Bool
│   │   - isSaved: Bool
│   │   - primaryDescription: String
│   │   - canViewFullDescription: Bool
│   │   - saveResult()
│   │   - shareResult() -> UIImage?
│   │   - toggleFullDescription()
│   │
│   ├── HistoryViewModel.swift
│   │   - historyItems: [AuraResult]
│   │   - favoriteItems: [AuraResult]
│   │   - selectedFilter: FilterType
│   │   - isLoading: Bool
│   │   - loadHistory()
│   │   - deleteItem(AuraResult)
│   │   - toggleFavorite(AuraResult)
│   │   - search(by: String) -> [AuraResult]
│   │   - getColorDistribution() -> [AuraColor: Int]
│   │
│   ├── SettingsViewModel.swift
│   │   - selectedCountry: SupportedCountries
│   │   - notificationsEnabled: Bool
│   │   - isPremium: Bool
│   │   - loadSettings()
│   │   - saveSettings()
│   │
│   └── PaywallViewModel.swift
│       - availableProducts: [SKProduct]
│       - isPurchasing: Bool
│       - selectedProduct: SKProduct?
│       - loadProducts()
│       - purchase(SKProduct)
│       - restore()
│
├── Views/
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   ├── OnboardingPageView.swift
│   │   └── OnboardingPage.swift (Model)
│   │
│   ├── Camera/
│   │   ├── CameraView.swift
│   │   ├── CameraPreviewView.swift
│   │   ├── CameraControlsView.swift
│   │   └── PermissionRequestView.swift
│   │
│   ├── Result/
│   │   ├── ResultView.swift
│   │   ├── AuraRingsView.swift
│   │   ├── ColorBreakdownView.swift
│   │   ├── DescriptionView.swift
│   │   └── ShareCardGenerator.swift
│   │
│   ├── History/
│   │   ├── HistoryView.swift
│   │   ├── HistoryRowView.swift
│   │   ├── HistoryDetailView.swift
│   │   └── FilterBar.swift
│   │
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── AccountSection.swift
│   │   ├── LocalizationSection.swift
│   │   └── AboutSection.swift
│   │
│   ├── Paywall/
│   │   ├── PaywallView.swift
│   │   ├── FeatureListView.swift
│   │   └── PricingCardView.swift
│   │
│   └── Components/
│       ├── AuraGradientView.swift
│       ├── LoadingView.swift
│       ├── ErrorView.swift
│       └── PremiumBadge.swift
│
├── Services/
│   ├── AuraEngine/
│   │   ├── AuraDetectionService.swift
│   │   │   - detectAura(from: UIImage) -> Result<AuraResult, Error>
│   │   │   - detectFace(in: UIImage) -> Result<VNFaceObservation, Error>
│   │   │   - extractAuraRegion(from: UIImage, face: VNFaceObservation) -> UIImage?
│   │   │   - analyzeAuraColors(from: UIImage) -> AuraResult?
│   │   │
│   │   ├── ColorAnalyzer.swift
│   │   │   - extractDominantColors(from: UIImage, count: Int) -> [UIColor]
│   │   │   - mapToAuraColor(UIColor) -> AuraColor?
│   │   │   - performKMeans(on: [HSVColor], k: Int) -> [HSVColor]
│   │   │   - rgbToHSV(r: CGFloat, g: CGFloat, b: CGFloat) -> HSVColor
│   │   │
│   │   └── CoreMLAuraPredictor.swift (Phase 3)
│   │       - predict(from: UIImage) -> [AuraColor: Float]
│   │
│   ├── Storage/
│   │   ├── DataManager.swift
│   │   │   - saveAuraResult(AuraResult)
│   │   │   - fetchAllHistory() -> [AuraResult]
│   │   │   - fetchFavorites() -> [AuraResult]
│   │   │   - deleteHistory(AuraResult)
│   │   │   - toggleFavorite(AuraResult)
│   │   │
│   │   └── CoreDataStack.swift
│   │       - persistentContainer: NSPersistentContainer
│   │       - viewContext: NSManagedObjectContext
│   │       - saveContext()
│   │
│   ├── Localization/
│   │   ├── LocalizationService.swift
│   │   │   - getDescription(for: AuraColor, countryCode: String) -> LocalizedDescription?
│   │   │   - loadAuraDescriptions()
│   │   │   - getCurrentCountryCode() -> String
│   │   │
│   │   └── LocalizationManager.swift
│   │       - setLanguage(String)
│   │       - currentLanguage: String
│   │
│   ├── IAP/
│   │   ├── StoreKitManager.swift
│   │   │   - loadProducts()
│   │   │   - purchase(SKProduct)
│   │   │   - restorePurchases()
│   │   │   - validateReceipt()
│   │   │
│   │   └── SubscriptionManager.swift
│   │       - isPremiumUser: Bool
│   │       - subscriptionStatus: SubscriptionStatus
│   │       - checkSubscriptionStatus()
│   │
│   ├── Analytics/
│   │   ├── AnalyticsManager.swift
│   │   │   - logEvent(AnalyticsEvent, parameters: [String: Any])
│   │   │   - setUserProperty(key: String, value: String)
│   │   │   - trackScreen(String)
│   │   │
│   │   └── AnalyticsEvent.swift (Enum)
│   │       - app_open, onboarding_completed, scan_started...
│   │
│   └── Network/
│       ├── FirebaseManager.swift
│       │   - configureFirebase()
│       │   - fetchRemoteConfig()
│       │
│       └── APIService.swift (Optional Backend)
│           - validateSubscription(receipt: Data)
│           - syncHistory([AuraResult])
│
├── Resources/
│   ├── Localization/
│   │   ├── en.lproj/
│   │   │   └── Localizable.strings
│   │   ├── tr.lproj/
│   │   │   └── Localizable.strings
│   │   └── aura_comments.json
│   │       {
│   │         "aura_red": {
│   │           "default": {...},
│   │           "TR": {...},
│   │           "US": {...}
│   │         }
│   │       }
│   │
│   ├── Assets.xcassets/
│   │   ├── AppIcon.appiconset/
│   │   ├── Colors/
│   │   │   ├── AuraBackground.colorset
│   │   │   ├── AuraSurface.colorset
│   │   │   └── AuraAccent.colorset
│   │   └── Images/
│   │
│   ├── Fonts/
│   │   └── CustomFonts/
│   │
│   └── Sounds/
│       └── scan_complete.wav
│
├── Configuration/
│   ├── Info.plist
│   │   - NSCameraUsageDescription
│   │   - NSPhotoLibraryUsageDescription
│   │   - CFBundleDisplayName
│   │   - LSApplicationQueriesSchemes
│   │
│   ├── AuraColorFinder.entitlements
│   │   - In-App Purchase
│   │   - StoreKit Configuration
│   │
│   └── GoogleService-Info.plist (Firebase)
│
└── Tests/
    ├── AuraColorFinderTests/
    │   ├── AuraEngineTests/
    │   │   ├── ColorAnalyzerTests.swift
    │   │   └── AuraDetectionServiceTests.swift
    │   ├── ViewModelTests/
    │   │   ├── CameraViewModelTests.swift
    │   │   └── HistoryViewModelTests.swift
    │   └── ServiceTests/
    │       ├── DataManagerTests.swift
    │       └── LocalizationServiceTests.swift
    │
    └── AuraColorFinderUITests/
        ├── OnboardingFlowTests.swift
        ├── ScanFlowTests.swift
        └── HistoryTests.swift
```

---

## 4. AURA DETECTION PIPELINE (Detaylı)

### 4.1 Adım Adım İşlem Akışı

```
1. IMAGE CAPTURE
   ├─ Kaynak: AVCaptureSession veya Photo Library
   ├─ Format: UIImage (JPEG/PNG)
   ├─ Min Çözünürlük: 400x400 px
   └─ Output: UIImage

2. FACE DETECTION (Vision Framework)
   ├─ Input: UIImage
   ├─ Framework: Vision (VNDetectFaceRectanglesRequest)
   ├─ Detection: VNFaceObservation
   ├─ Koordinat Dönüşümü: Vision (bottom-left) → UIKit (top-left)
   └─ Output: CGRect (face bounding box)

3. AURA REGION EXTRACTION
   ├─ Input: Face bounding box
   ├─ Expansion Factor: 1.5x (yüz etrafı %50 genişletme)
   ├─ Boundary Check: Image bounds içinde tutma
   ├─ Crop: cgImage.cropping(to: expandedRect)
   └─ Output: UIImage (aura region)

4. IMAGE PREPROCESSING
   ├─ Downscale: 100x100 px (performans için)
   ├─ Blur: CIGaussianBlur (radius: 5.0)
   ├─ Purpose: Gürültü azaltma, renkler yumuşatma
   └─ Output: Preprocessed UIImage

5. PIXEL COLOR EXTRACTION
   ├─ Input: Preprocessed image
   ├─ Method: CGContext ile pixel data okuma
   ├─ Filtering: 
   │   - Çok koyu piksel (v < 0.1) → atla
   │   - Çok açık piksel (v > 0.95) → atla
   │   - Düşük saturasyon (s < 0.1) → atla
   └─ Output: [HSVColor] array

6. HSV COLOR SPACE CONVERSION
   ├─ Input: RGB pixels (r, g, b)
   ├─ Algorithm:
   │   max = max(r, g, b)
   │   min = min(r, g, b)
   │   delta = max - min
   │   
   │   v = max
   │   s = delta / max (if max != 0)
   │   
   │   if r == max: h = (g - b) / delta
   │   if g == max: h = 2 + (b - r) / delta
   │   if b == max: h = 4 + (r - g) / delta
   │   h = h * 60° (normalize to 0-360)
   │   
   └─ Output: HSVColor(h, s, v)

7. K-MEANS CLUSTERING
   ├─ Input: [HSVColor] array
   ├─ Parameters:
   │   - k = 3 (3 dominant color)
   │   - maxIterations = 20
   │   - Distance metric: Euclidean in HSV space
   │   
   ├─ Algorithm:
   │   1. Random k renk merkezi seç
   │   2. Her pikseli en yakın merkeze ata
   │   3. Her cluster'ın ortalamasını al (yeni merkezler)
   │   4. Convergence kontrolü
   │   5. Repeat or terminate
   │   
   └─ Output: [HSVColor] (3 cluster merkezi)

8. AURA COLOR MAPPING
   ├─ Input: 3 HSV cluster merkezi
   ├─ Predefined Aura Colors:
   │   - Red: hue 0-20°, s≥0.5, v≥0.4
   │   - Orange: hue 21-40°, s≥0.5, v≥0.4
   │   - Yellow: hue 41-70°, s≥0.4, v≥0.5
   │   - Green: hue 71-150°, s≥0.3, v≥0.3
   │   - Blue: hue 151-240°, s≥0.3, v≥0.3
   │   - Purple: hue 241-290°, s≥0.4, v≥0.3
   │   - Pink: hue 291-330°, s≥0.4, v≥0.5
   │   - White: any hue, s<0.2, v≥0.8
   │   
   ├─ Mapping Logic:
   │   For each cluster center:
   │     - Check hue, saturation, brightness against ranges
   │     - If match → assign AuraColor
   │     - If no match → find closest by hue distance
   │   
   └─ Output: [AuraColor] (primary, secondary, tertiary)

9. DOMINANCE PERCENTAGE CALCULATION
   ├─ Input: 3 mapped aura colors
   ├─ Simple Method (MVP):
   │   primary = 60%
   │   secondary = 25%
   │   tertiary = 15%
   │   
   ├─ Advanced Method (Phase 2):
   │   Count pixels in each cluster
   │   percentage = (cluster_size / total_pixels) * 100
   │   
   └─ Output: [Double] (percentages)

10. RESULT OBJECT CREATION
    ├─ Input: All processed data
    ├─ AuraResult:
    │   - id: UUID()
    │   - timestamp: Date()
    │   - primaryColor: AuraColor
    │   - secondaryColor: AuraColor?
    │   - tertiaryColor: AuraColor?
    │   - dominancePercentages: [Double]
    │   - countryCode: Locale.current.regionCode
    │   - imageData: capturedImage.jpegData()
    │   
    └─ Output: AuraResult

11. LOCALIZATION LOOKUP
    ├─ Input: AuraResult + countryCode
    ├─ LocalizationService:
    │   - Load aura_comments.json
    │   - Get description for primaryColor + countryCode
    │   - Fallback to "default" if country not found
    │   
    └─ Output: LocalizedDescription

12. PERSISTENCE & DISPLAY
    ├─ Save to Core Data (optional)
    ├─ Update ViewModel state
    ├─ Navigate to ResultView
    └─ Display aura rings + description
```

### 4.2 Error Handling

```swift
enum AuraDetectionError: LocalizedError {
    case noFaceDetected          // Yüz bulunamadı
    case imageTooSmall           // Görüntü çözünürlüğü düşük
    case processingFailed        // İşlem hatası
    case invalidImage            // Geçersiz görüntü formatı
    case noAuraColorFound        // Aura rengi tespit edilemedi
    case timeout                 // İşlem zaman aşımı (30s)
}
```

### 4.3 Performance Optimizations

- **Async Processing:** DispatchQueue.global(qos: .userInitiated)
- **Image Downsampling:** 100x100 px (orijinal boyutun %10'u)
- **Early Termination:** k-means convergence kontrolü
- **Memory Management:** AutoreleasePool kullanımı
- **Cache:** Predefined aura colors dictionary

---

## 5. MULTI-COUNTRY LOCALIZATION

### 5.1 Desteklenen Ülkeler

| Ülke | Kod | Bayrak | Dil | Kültürel Adaptasyon |
|------|-----|--------|-----|---------------------|
| United States | US | 🇺🇸 | English | Western spirituality |
| Turkey | TR | 🇹🇷 | Türkçe | Eastern mysticism |
| United Kingdom | UK | 🇬🇧 | English | Celtic traditions |
| Germany | DE | 🇩🇪 | Deutsch | European esotericism |
| France | FR | 🇫🇷 | Français | Romantic spirituality |

### 5.2 Localization Stratejisi

#### A) UI Strings (Localizable.strings)
```
// en.lproj/Localizable.strings
"onboarding.title" = "Discover Your Aura";
"camera.permission.title" = "Camera Access Required";
"result.primary.label" = "Primary Aura";

// tr.lproj/Localizable.strings
"onboarding.title" = "Auranızı Keşfedin";
"camera.permission.title" = "Kamera Erişimi Gerekli";
"result.primary.label" = "Birincil Aura";
```

#### B) Aura Descriptions (JSON)
```json
{
  "aura_blue": {
    "default": {
      "countryCode": "default",
      "short": "Calm and intuitive",
      "long": "Blue aura indicates calmness, intuition, and strong communication skills.",
      "traits": ["Calm", "Intuitive", "Communicative"],
      "advice": "Trust your intuition and speak your truth."
    },
    "TR": {
      "countryCode": "TR",
      "short": "Sakinlik ve sezgi",
      "long": "Mavi aura sakinliği, sezgiyi ve güçlü iletişim becerilerini gösterir.",
      "traits": ["Sakin", "Sezgisel", "İletişim yeteneği yüksek"],
      "advice": "Sezgilerinize güvenin ve gerçeğinizi konuşun."
    }
  }
}
```

### 5.3 Localization Service Implementation

```
LocalizationService:
  1. App başlangıcında JSON'u yükle
  2. Kullanıcının country code'unu al (Locale.current.regionCode)
  3. AuraResult için uygun description'ı getir
  4. Fallback chain: specific country → default → error
  5. Cache mekanizması (performans için)
```

---

## 6. MONETIZATION: IAP & CREDITS

### 6.1 Subscription Model (Primary)

#### Product IDs
- `com.auracolorfinder.premium.monthly` - Aylık: $4.99
- `com.auracolorfinder.premium.yearly` - Yıllık: $39.99 (2 ay bedava)

#### Premium Features
1. **Unlimited Scans** - Günlük limit yok
2. **Long Descriptions** - Detaylı aura yorumları
3. **Aura Trends** - Zaman içindeki aura değişim grafiği
4. **Priority Support** - Öncelikli destek
5. **No Ads** - Reklamsız deneyim (eğer ads eklenirse)

#### Free Tier Limits
- 3 tarama/gün
- Kısa yorumlar (2-3 cümle)
- Trend grafiği yok

### 6.2 Credits System (Alternative/Secondary)

#### Logic
```
1 Credit = 1 Aura Scan

Credit Packages:
- 5 Credits: $2.99
- 15 Credits: $6.99 (30% discount)
- 50 Credits: $19.99 (40% discount)

Premium users: Unlimited credits (no deduction)
```

#### Firebase Implementation
```
Firestore Structure:
credits/
  {userId}/
    balance: Int
    transactions: [
      {
        id: String,
        amount: Int,
        type: "purchase" | "usage",
        timestamp: Timestamp
      }
    ]

Cloud Function:
onScanComplete(userId):
  1. Check if user is premium
  2. If not, deduct 1 credit
  3. If insufficient, show paywall
  4. Log transaction
```

### 6.3 StoreKit Implementation

```swift
StoreKitManager:
  - loadProducts() 
    → Request products from App Store Connect
  
  - purchase(product: SKProduct)
    → SKPaymentQueue.add(payment)
    → Handle transaction states
    → Validate receipt (local or server)
    → Unlock premium features
  
  - restorePurchases()
    → SKPaymentQueue.restoreCompletedTransactions()
    → Re-validate active subscriptions
  
  - validateReceipt(receiptData: Data)
    → Option 1: Local validation (base64 decode + parse)
    → Option 2: Server validation (Firebase Cloud Function)
```

### 6.4 Paywall Trigger Points

1. **Daily Limit Reached** - After 3rd scan (free users)
2. **Long Description Tap** - "Unlock full interpretation"
3. **Trend Graph Tap** - "See your aura trends"
4. **Settings Premium Badge** - "Upgrade to Premium"
5. **After 7 Days** - Soft reminder modal

---

## 7. UI/UX AKIŞI ve EKRAN DETAYları

### 7.1 Ekran Akış Diagramı

```
┌──────────────┐
│  App Launch  │
└──────┬───────┘
       │
       ├─ First Time? ─YES─→ ┌───────────────┐
       │                     │  Onboarding   │
       │                     │  (3 pages)    │
       │                     └───────┬───────┘
       │                             │
       └─ Returning User ─NO────────┐│
                                     ││
                                     ↓↓
                            ┌─────────────────┐
                            │  Camera View    │
                            │  (Main Screen)  │
                            └────┬────────┬───┘
                                 │        │
                    ┌────────────┘        └───────────┐
                    ↓                                  ↓
            ┌───────────────┐                 ┌────────────────┐
            │ History View  │                 │  Settings View │
            └───────┬───────┘                 └────────────────┘
                    │
          ┌─────────┼─────────┐
          ↓         ↓         ↓
    [Detail]  [Favorites] [Delete]

Camera View → [Capture] → [Processing] → ┌─────────────────┐
                                          │  Result View    │
                                          │  (Aura Rings)   │
                                          └────┬────────────┘
                                               │
                                   ┌───────────┼───────────┐
                                   ↓           ↓           ↓
                              [Save]      [Share]    [Scan Again]
```

### 7.2 Ekran Detayları

#### Onboarding (3 Pages)
```
Page 1: "Discover Your Aura"
  - Icon: sparkles
  - Description: "Reveal the colors of your energy field"
  
Page 2: "Personalized Insights"
  - Icon: globe
  - Description: "Get culturally adapted interpretations"
  
Page 3: "Track Your Journey"
  - Icon: chart.line.uptrend
  - Description: "Monitor how your aura changes"
  
[Continue] → [Get Started]
```

#### Camera View
```
┌─────────────────────────────────────┐
│ Header:                             │
│  "Aura Scanner"  [History] [Settings]│
├─────────────────────────────────────┤
│                                     │
│     ┌───────────────────────┐       │
│     │                       │       │
│     │   Camera Preview      │       │
│     │   (AVCaptureSession)  │       │
│     │                       │       │
│     │   [Face Overlay]      │       │
│     │                       │       │
│     └───────────────────────┘       │
│                                     │
│  "Position your face in the center" │
│                                     │
│  [●] 3 scans remaining today        │
│      [Upgrade to unlimited]         │
│                                     │
├─────────────────────────────────────┤
│ Controls:                           │
│  [Gallery]   [●  CAPTURE  ●]  [Info]│
└─────────────────────────────────────┘
```

#### Result View
```
┌─────────────────────────────────────┐
│ [X]     "Your Aura"          [Share]│
├─────────────────────────────────────┤
│                                     │
│        ┌─────────────┐              │
│       ╱               ╲             │
│      │    ███████     │  ← Primary  │
│     │   ███████████   │             │
│      │  ███████████  │   ← Secondary│
│       ╲ ███████████ ╱              │
│        └─────────────┘              │
│                                     │
│  Color Composition:                 │
│  ┌─────────────────────────────┐   │
│  │ ⚫ Blue         60%          │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ ⚫ Purple       25%          │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ ⚫ Pink         15%          │   │
│  └─────────────────────────────┘   │
│                                     │
│  Interpretation:                    │
│  ┌─────────────────────────────┐   │
│  │ Blue aura indicates calm... │   │
│  │ ... [Read full 👑]          │   │
│  └─────────────────────────────┘   │
│                                     │
│  [💾 Save to History]               │
│  [🔄 Scan Again]                    │
└─────────────────────────────────────┘
```

#### History View
```
┌─────────────────────────────────────┐
│ [<] Scan History             [Trash]│
├─────────────────────────────────────┤
│ Filters: [All] [Favorites]   12 scans│
├─────────────────────────────────────┤
│                                     │
│ ┌─────────────────────────────┐     │
│ │ ⚫ Blue with Purple         │     │
│ │    Nov 17, 2024 14:32     ⭐│     │
│ └─────────────────────────────┘     │
│                                     │
│ ┌─────────────────────────────┐     │
│ │ ⚫ Yellow with Green        │     │
│ │    Nov 15, 2024 09:15      │     │
│ └─────────────────────────────┘     │
│                                     │
│ ┌─────────────────────────────┐     │
│ │ ⚫ Purple                   │     │
│ │    Nov 12, 2024 18:45     ⭐│     │
│ └─────────────────────────────┘     │
│                                     │
│      [Load More]                    │
└─────────────────────────────────────┘
```

#### Paywall View
```
┌─────────────────────────────────────┐
│                            [X]      │
│                                     │
│            👑                       │
│                                     │
│      Unlock Premium                 │
│                                     │
│  Get unlimited access to all        │
│       features                      │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ∞  Unlimited Scans          │   │
│  │ 📄 Detailed Descriptions    │   │
│  │ 📈 Aura Trends              │   │
│  │ 👁️  Ad-Free Experience       │   │
│  │ 👤 Priority Support         │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │   Start Free Trial          │   │
│  │   Then $4.99/month          │   │
│  └─────────────────────────────┘   │
│                                     │
│     Terms & Conditions              │
└─────────────────────────────────────┘
```

### 7.3 Design System

#### Colors
```swift
// Dark Theme (Default)
auraBackground = #0A0A0F  // Deep black-blue
auraSurface = #1A1A2E     // Dark surface
auraAccent = #6C5CE7      // Purple accent
auraText = #FFFFFF        // White text
auraTextSecondary = #A0A0B0 // Light gray

// Aura Colors (Predefined)
auraRed = #FF0000
auraOrange = #FF8800
auraYellow = #FFFF00
auraGreen = #00FF00
auraBlue = #0088FF
auraPurple = #8800FF
auraPink = #FF00FF
auraWhite = #FFFFFF
```

#### Typography
```swift
Title: SF Pro Display, 32pt, Bold
Headline: SF Pro Text, 18pt, Semibold
Body: SF Pro Text, 16pt, Regular
Caption: SF Pro Text, 12pt, Regular
```

#### Spacing
```swift
smallPadding = 8pt
padding = 16pt
largePadding = 24pt
cornerRadius = 16pt
buttonHeight = 56pt
```

#### Animations
```swift
defaultDuration = 0.3s
springResponse = 0.5
springDamping = 0.7
pulseAnimation = easeInOut(1.5s).repeatForever()
```

---

## 8. TEST STRATEJİSİ

### 8.1 Unit Tests

#### AuraEngine Tests
```swift
ColorAnalyzerTests:
  - testRGBtoHSVConversion()
  - testKMeansWithKnownData()
  - testColorMapping()
  - testEdgeCases() // all black, all white
  
AuraDetectionServiceTests:
  - testFaceDetectionWithValidImage()
  - testFaceDetectionWithNoFace()
  - testAuraRegionExtraction()
  - testFullPipeline()
```

#### ViewModel Tests
```swift
CameraViewModelTests:
  - testDailyScanLimit()
  - testPermissionHandling()
  - testImageProcessing()
  
HistoryViewModelTests:
  - testLoadHistory()
  - testFiltering()
  - testSearch()
  - testColorDistribution()
```

#### Service Tests
```swift
DataManagerTests:
  - testSaveAuraResult()
  - testFetchHistory()
  - testDeleteHistory()
  
LocalizationServiceTests:
  - testGetDescriptionForCountry()
  - testFallbackToDefault()
  - testJSONParsing()
```

### 8.2 UI Tests

```swift
OnboardingFlowTests:
  - testCompleteOnboardingFlow()
  - testSkipOnboarding()
  
ScanFlowTests:
  - testCameraPermissionRequest()
  - testImageCapture()
  - testResultDisplay()
  - testSaveToHistory()
  
HistoryTests:
  - testHistoryListDisplay()
  - testFavoriteToggle()
  - testHistoryDetail()
```

### 8.3 Integration Tests

```swift
End-to-End Tests:
  - testFullScanWorkflow()
    1. Launch app
    2. Complete onboarding
    3. Grant camera permission
    4. Capture photo
    5. Wait for processing
    6. Verify result screen
    7. Save to history
    8. Verify in history list
```

### 8.4 TestFlight Beta Testing

#### Test Scenarios
1. **Device Compatibility**
   - iPhone SE (smallest)
   - iPhone 14 Pro Max (largest)
   - iPad (adaptif layout)

2. **Lighting Conditions**
   - Bright daylight
   - Indoor lighting
   - Low light
   - Backlit scenarios

3. **Performance**
   - Processing time < 5 seconds
   - Memory usage < 150MB
   - Battery drain monitoring

4. **Edge Cases**
   - No face in photo
   - Multiple faces
   - Side profile
   - Wearing sunglasses/mask

---

## 9. RELEASE PLAN

### 9.1 App Store Connect Kurulum

#### App Information
```
Name: Aura Color Finder
Subtitle: Discover Your Energy Colors
Category: Lifestyle > Health & Fitness
Content Rating: 4+
Languages: English, Turkish
```

#### Privacy
```
Data Collection:
  - Camera (required): Aura detection
  - Photo Library (optional): Select existing photos
  - Analytics (optional): Usage statistics
  
Data NOT Collected:
  - No personal information
  - Photos not uploaded to server
  - On-device processing only
```

#### In-App Purchases
```
- Monthly Premium: Auto-renewable subscription
- Yearly Premium: Auto-renewable subscription
- (Optional) Credit packs: Consumable
```

### 9.2 App Store Assets

#### Screenshots (6.7" Display)
1. Onboarding hero screen
2. Camera interface
3. Result screen with aura rings
4. History screen
5. Premium features showcase

#### Localized Descriptions

**English:**
```
Title: Aura Color Finder - Discover Your Energy

Description:
Discover the colors of your aura with advanced AI-powered analysis. 
Get personalized insights based on your cultural background.

Features:
• Instant aura color detection
• Culturally adapted interpretations
• Track your aura over time
• Beautiful visualizations
• Share your results
```

**Turkish:**
```
Title: Aura Renk Bulucu - Enerjini Keşfet

Description:
Gelişmiş yapay zeka destekli analizle auranızın renklerini keşfedin.
Kültürel arka planınıza göre kişiselleştirilmiş içgörüler edinin.

Özellikler:
• Anında aura renk tespiti
• Kültürel adaptasyonlu yorumlar
• Auranızı zaman içinde takip edin
• Güzel görseller
• Sonuçlarınızı paylaşın
```

### 9.3 Release Checklist

#### Pre-submission
- [ ] All features complete and tested
- [ ] Unit tests passing (>80% coverage)
- [ ] UI tests passing
- [ ] TestFlight beta tested (min 10 users)
- [ ] Privacy Policy published
- [ ] Terms of Service published
- [ ] All localizations complete
- [ ] App icons (all sizes)
- [ ] Screenshots (all devices + locales)
- [ ] App Store description written
- [ ] IAP products configured
- [ ] Analytics integrated
- [ ] Crashlytics integrated

#### Submission
- [ ] Archive and upload to App Store Connect
- [ ] Fill out App Store metadata
- [ ] Submit for review
- [ ] Monitor review status

#### Post-approval
- [ ] Release to 10% of users (phased release)
- [ ] Monitor crashes and errors
- [ ] Monitor reviews
- [ ] Gradual rollout to 100%

---

## 10. ROADMAP & SPRINT PLAN

### 10.1 Phase 1 - MVP (6 Hafta)

#### Sprint 1 (2 Hafta): Foundation
**Goals:**
- Proje kurulumu
- Temel mimari
- Kamera + Vision entegrasyonu

**Tasks:**
- [ ] Xcode projesi oluştur
- [ ] MVVM klasör yapısı kur
- [ ] Core Data model tanımla
- [ ] Constants ve extensions ekle
- [ ] Camera permission flow
- [ ] AVCaptureSession kurulumu
- [ ] Vision face detection entegrasyonu
- [ ] UI: Onboarding screens
- [ ] UI: Camera view basic layout

**Deliverables:**
- Çalışan kamera
- Yüz tespiti çalışıyor
- Onboarding akışı tamamlandı

#### Sprint 2 (2 Hafta): Aura Engine
**Goals:**
- Aura detection algorithm
- Result screen
- Color analysis

**Tasks:**
- [ ] HSV renk dönüşümü implement et
- [ ] k-means clustering algorithm
- [ ] Aura color mapping logic
- [ ] AuraDetectionService tamamla
- [ ] ColorAnalyzer service
- [ ] UI: Result screen
- [ ] UI: Aura rings animation
- [ ] Unit tests (AuraEngine)

**Deliverables:**
- Çalışan aura detection
- Result ekranı
- Test coverage >70%

#### Sprint 3 (2 Hafta): History & Localization
**Goals:**
- Scan history
- Multi-country support
- Settings

**Tasks:**
- [ ] Core Data CRUD operations
- [ ] DataManager service
- [ ] LocalizationService
- [ ] aura_comments.json (EN, TR)
- [ ] UI: History list
- [ ] UI: History detail
- [ ] UI: Settings screen
- [ ] Country selection
- [ ] UI tests (main flows)

**Deliverables:**
- History çalışıyor
- TR ve EN localization
- Settings complete

### 10.2 Phase 2 - Expansion (6 Hafta)

#### Sprint 4 (2 Hafta): IAP & Paywall
**Goals:**
- Premium subscription
- Paywall implementation

**Tasks:**
- [ ] StoreKit manager
- [ ] IAP products (App Store Connect)
- [ ] SubscriptionManager
- [ ] Daily scan limit logic
- [ ] UI: Paywall screen
- [ ] Premium badge & CTAs
- [ ] Receipt validation
- [ ] Restore purchases

**Deliverables:**
- IAP çalışıyor
- Paywall tetikleniyor
- Free/Premium ayrımı

#### Sprint 5 (2 Hafta): Extended Localization
**Goals:**
- 5 ülke desteği (TR/US/DE/UK/FR)
- Advanced descriptions

**Tasks:**
- [ ] DE, UK, FR localization
- [ ] aura_comments.json genişlet
- [ ] Kültürel adaptasyon
- [ ] Long descriptions (premium)
- [ ] Traits ve advice sections
- [ ] Localization tests

**Deliverables:**
- 5 ülke desteği
- Kültürel farklar yansıtıldı

#### Sprint 6 (2 Hafta): Trends & Analytics
**Goals:**
- Aura trend graphs
- Analytics integration

**Tasks:**
- [ ] Trend graph component
- [ ] Historical data analysis
- [ ] Charts library (SwiftUI Charts)
- [ ] Firebase Analytics
- [ ] Event tracking
- [ ] User properties
- [ ] Remote Config setup

**Deliverables:**
- Trend grafiği (premium)
- Analytics çalışıyor

### 10.3 Phase 3 - ML Upgrade (8+ Hafta)

#### Sprint 7-8: CoreML Integration
**Goals:**
- ML model eğitimi
- CoreML integration

**Tasks:**
- [ ] Veri seti toplama
- [ ] Manuel etiketleme (min 1000 sample)
- [ ] Data augmentation
- [ ] Model architecture (MobileNet)
- [ ] Model eğitimi (Python/TensorFlow)
- [ ] CoreML conversion
- [ ] CoreML model entegrasyonu
- [ ] A/B testing (heuristic vs ML)

**Deliverables:**
- CoreML model
- Improved accuracy
- Performance karşılaştırması

### 10.4 Milestone Timeline

```
Week 1-2:   Sprint 1 - Foundation
Week 3-4:   Sprint 2 - Aura Engine
Week 5-6:   Sprint 3 - History & Localization
Week 7-8:   Sprint 4 - IAP & Paywall
Week 9-10:  Sprint 5 - Extended Localization
Week 11-12: Sprint 6 - Trends & Analytics
Week 13-14: TestFlight Beta Testing
Week 15-16: Bug Fixes & Polishing
Week 17:    App Store Submission
Week 18+:   Phase 3 Planning & ML Development
```

---

## 11. TEKNIK BAĞIMLILIKLAR

### 11.1 Native iOS Frameworks

```swift
import SwiftUI              // UI framework
import Combine             // Reactive programming
import Vision              // Face detection
import CoreImage           // Image processing
import AVFoundation        // Camera capture
import CoreData            // Local persistence
import StoreKit            // In-app purchases
import Photos              // Photo library access
import UIKit               // UIImage, UIColor
```

### 11.2 Third-Party (Optional)

```ruby
# Podfile
pod 'Firebase/Analytics'
pod 'Firebase/Crashlytics'
pod 'Firebase/RemoteConfig'
pod 'Amplitude-iOS'  # Alternative analytics
```

### 11.3 Backend Services (Optional)

- **Firebase:**
  - Authentication (anonim veya email)
  - Firestore (cloud sync)
  - Cloud Functions (receipt validation)
  - Remote Config (feature flags)
  - Analytics
  - Crashlytics

- **Alternative:**
  - Supabase (open-source Firebase alternative)

### 11.4 Development Tools

- Xcode 14.0+
- Swift 5.7+
- iOS Deployment Target: 15.0+
- Git (version control)
- Postman (API testing)
- Charles Proxy (network debugging)

---

## 12. GÜVENLİK VE GİZLİLİK

### 12.1 Privacy-First Approach

1. **On-Device Processing**
   - Tüm görüntü işleme cihazda
   - Fotoğraflar asla sunucuya yüklenmez
   - Network gerektirmez (offline çalışır)

2. **Data Minimization**
   - Sadece gerekli veriler saklanır
   - imageData optional (kullanıcı seçimi)
   - Hiçbir kişisel bilgi toplamıyoruz

3. **User Control**
   - History silme özelliği
   - Fotoğraf saklama opt-in
   - Analytics opt-out seçeneği

### 12.2 App Store Privacy Labels

```
Data Used to Track You: None

Data Linked to You: None

Data Not Linked to You:
  - Usage Data (Analytics)
    - Optional
    - Used for app improvement
```

### 12.3 Legal Documents

#### Privacy Policy (Zorunlu)
- Hangi verileri topladığımız
- Nasıl kullandığımız
- Üçüncü parti paylaşımlar (yok)
- Kullanıcı hakları

#### Terms of Service (Zorunlu)
- Uygulama kullanım şartları
- "Eğlence amaçlıdır" disclaimer
- Sorumluluk reddi
- Abonelik şartları

### 12.4 Disclaimer

```
Tüm ekranlarda görünür:
"This app is for entertainment purposes only. 
Aura readings are not scientifically proven and 
should not be used for medical or professional advice."
```

---

## 13. PERFORMANCE METRICS

### 13.1 Key Performance Indicators (KPIs)

#### Technical Metrics
- **Processing Time:** < 5 seconds (average)
- **Memory Usage:** < 150MB (peak)
- **Battery Drain:** < 5% per scan
- **Crash Rate:** < 0.5%
- **App Size:** < 50MB (initial download)

#### Business Metrics
- **DAU (Daily Active Users)**
- **Retention Rate:** 
  - D1: >40%
  - D7: >20%
  - D30: >10%
- **Conversion Rate (Free→Premium):** >5%
- **Average Scans per User:** >5 (first week)
- **Session Duration:** >2 minutes

### 13.2 Analytics Events (Detaylı)

```swift
// User Lifecycle
- app_open
- onboarding_started
- onboarding_page_viewed(page: Int)
- onboarding_completed

// Permissions
- camera_permission_requested
- camera_permission_granted
- camera_permission_denied
- camera_permission_settings_opened

// Scanning
- scan_started(source: "camera" | "gallery")
- scan_processing
- scan_completed(
    primary_color: String,
    secondary_color: String?,
    processing_time: Double
  )
- scan_failed(error: String)

// Result Actions
- result_viewed
- result_saved
- result_shared(platform: String)
- full_description_tapped(is_premium: Bool)

// History
- history_viewed
- history_item_tapped
- history_deleted
- history_favorited

// Monetization
- paywall_viewed(trigger: String)
- purchase_initiated(product_id: String)
- purchase_completed(product_id: String, price: String)
- purchase_failed(error: String)
- purchase_restored
- subscription_expired

// Settings
- settings_opened
- country_changed(from: String, to: String)
- language_changed(from: String, to: String)
```

---

## 14. SONUÇ VE SONRAKİ ADIMLAR

### 14.1 Proje Özeti

Bu dokümanda Aura Color Finder iOS uygulamasının:
- ✅ Tam teknik mimarisi
- ✅ Detaylı klasör yapısı ve dosya organizasyonu
- ✅ Tüm servisler ve sorumlulukları
- ✅ MVVM katmanları ve data flow
- ✅ Aura detection pipeline'ı (11 adım)
- ✅ Multi-country localization stratejisi
- ✅ IAP & Credits monetization sistemi
- ✅ UI/UX akışı ve ekran detayları
- ✅ Test stratejisi
- ✅ Release planı
- ✅ 3 fazlı roadmap (20 hafta)
- ✅ Sprint planları

planlanmıştır.

### 14.2 Hemen Başlanabilir

Bu plan ile:
1. Xcode projesini oluştur
2. Sprint 1'e başla
3. İki haftada ilk demo hazır
4. 6 haftada MVP launch

### 14.3 Başarı Kriterleri

**MVP Launch (Week 6):**
- [ ] Aura detection çalışıyor
- [ ] EN + TR localization
- [ ] History feature
- [ ] TestFlight beta

**Phase 2 Complete (Week 12):**
- [ ] IAP entegre
- [ ] 5 ülke desteği
- [ ] Premium features
- [ ] App Store'da yayında

**Phase 3 Complete (Week 20+):**
- [ ] CoreML model
- [ ] Gelişmiş accuracy
- [ ] Kullanıcı feedback entegre

---

## 15. İLETİŞİM VE KAYNAKLAR

### 15.1 Referans Dokümanlar
- **Source of Truth:** aura_color.md
- **Technical Plan:** Bu doküman
- **API Docs:** (TBD - backend eklenirse)

### 15.2 Useful Links
- [Apple HIG](https://developer.apple.com/design/human-interface-guidelines/)
- [Vision Framework Docs](https://developer.apple.com/documentation/vision)
- [StoreKit Docs](https://developer.apple.com/documentation/storekit)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)

### 15.3 Ekip Rolleri (Önerilen)
- **iOS Developer (Lead):** Tüm iOS development
- **UI/UX Designer:** Ekran tasarımları, assets
- **Backend Developer (Optional):** Firebase/Cloud Functions
- **ML Engineer (Phase 3):** CoreML model eğitimi
- **QA Tester:** TestFlight koordinasyonu
- **Content Writer:** Aura descriptions (5 dil)

---

**Son Güncelleme:** Kasım 2024  
**Doküman Versiyonu:** 1.0  
**Durum:** ✅ Planlama Tamamlandı - Geliştirme Başlayabilir

