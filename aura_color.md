1. Introduction

Bu belge, Aura Color Finder uygulamasının uçtan uca geliştirilmesi için gerekli tüm ürün, teknik mimari, altyapı, tasarım, veri modeli, monetizasyon, test ve yayın süreçlerini içeren kapsamlı bir proje planıdır.
Uygulama tamamen iOS odaklıdır ve SwiftUI + MVVM mimarisini temel alır. Aura tespiti on-device görüntü işleme ile yapılır, ileri aşamalarda CoreML modeli entegre edilebilir.

⸻

2. Product Overview

Aura Color Finder, kullanıcının fotoğrafından aura renklerini analiz eden, bu renklerin yorumlarını kültüre göre gösteren, çok ülkeli bir mobil uygulamadır.
Uygulama hem eğlence amaçlı hem de günlük içgörü sağlayacak şekilde tasarlanır.

⸻

3. Target Users
	•	Spiritüel veya astroloji temelli içeriklerle ilgilenen kullanıcılar.
	•	Meditasyon ve farkındalık uygulamalarını seven kişiler.
	•	Sosyal medyada içerik paylaşmayı seven genç kullanıcılar.
	•	Kendisi hakkında eğlenceli analizler elde etmek isteyen herkes.

⸻

4. Core Features
	•	Kamera ile aura taraması.
	•	Vision framework ile yüz tespiti.
	•	Aura bölgesi segmentasyonu.
	•	Dominant aura renklerinin çıkarımı (HSV + k-means).
	•	1–3 dominant aura rengi.
	•	Çok ülkeli aura yorumları.
	•	Geçmiş aura sonuçları (history).
	•	Aura renk halkası animasyonu.
	•	Paylaşılabilir sonuç kartları.
	•	Premium: sınırsız tarama, uzun yorumlar, aura trend grafiği.

⸻

5. Architecture Overview

5.1 System Components
	•	iOS Uygulaması (SwiftUI + MVVM)
	•	AuraEngine (on-device görüntü işleme)
	•	Opsiyonel Backend (yorum içerikleri, abonelik doğrulama)
	•	Firebase/Supabase (opsiyonel bulut)
	•	Analytics (Firebase/Amplitude)

⸻

6. iOS Architecture (SwiftUI + MVVM)

6.1 Project Structure
AuraColorFinder/
 ├── Views/
 ├── ViewModels/
 ├── Services/
 ├── Models/
 ├── Resources/
 └── Core/
 6.2 MVVM Flow
	•	View → ViewModel’e kullanıcı aksiyonu gönderir.
	•	ViewModel → Service katmanını kullanır.
	•	Service → görüntü işleme, depolama, localization gibi işleri yapar.
	•	Model → tüm veri varlıklarını temsil eder.

⸻

7. Aura Detection Engine

7.1 Processing Pipeline
	1.	Kamera ile fotoğraf çekilir.
	2.	Vision ile yüz tespiti yapılır.
	3.	Yüz kutusunun etrafı genişletilerek “aura bölgesi” belirlenir.
	4.	Aura bölgesi blur + downscale ile yumuşatılır.
	5.	HSV renk uzayına dönüştürülür.
	6.	k-means (k=3) ile dominant renk kümeleri çıkarılır.
	7.	Renk merkezleri aura renk haritasına eşlenir.
	8.	Sonuç objesi oluşturulur.

7.2 Aura Color Model
AuraColor {
  id: String
  hueRange: [min,max]
  saturationMin: Double
  brightnessMin: Double
  localizedDescriptions: { countryCode: {...} }
}
8. CoreML Integration (Optional)

8.1 Model Design
	•	Input: aura bölgesinin 224x224 crop’u.
	•	Output: aura renklerine karşı olasılık dağılımı.
	•	Architecture: MobileNet tabanlı hafif CNN.

8.2 Training Pipeline
	•	Veri toplanır ve manuel olarak aura rengi etiketlenir.
	•	Augmentation uygulanır.
	•	Eğitim → değerlendirme → CoreML dönüşümü yapılır.
	•	Uygulamaya eklenir.

⸻

9. Multi-Country Localization & Cultural Adaptation

9.1 Localization Strategy
	•	Tüm UI string’leri Localizable.strings içinde tutulur.
	•	Aura yorumları JSON formatında ülkeler bazında tutulur.
	•	TR / US / DE / UK / FR varyantları başlangıç için yeterlidir.

9.2 Aura Comment JSON Example
{
  "aura_yellow": {
    "default": {
      "short": "Clarity and optimism.",
      "long": "Yellow aura reflects intellectual clarity..."
    },
    "TR": {
      "short": "Açıklık ve iyimserlik.",
      "long": "Sarı aura zihinsel berraklığı ve neşeyi temsil eder..."
    }
  }
}
10. Data Storage

10.1 Local
	•	Core Data veya SQLite.
	•	History kayıtları: id, date, countryCode, primaryColorId, hex değeri vs.
	•	Kullanıcı ayarları: dil, ülke, tema, izinler.

10.2 Cloud Sync (Future)
	•	Firestore veya Supabase ile senkronizasyon.

⸻

11. Backend & Cloud (Optional)

11.1 Backend Responsibilities
	•	Aura yorumlarının yönetimi.
	•	Ülke bazlı içerik konfigürasyonu.
	•	Abonelik doğrulama (StoreKit sunucu doğrulama).
	•	Remote Config.

11.2 Recommended Stack
	•	Firebase Auth
	•	Firestore
	•	Cloud Functions
	•	Remote Config

⸻

12. Security, Privacy & Legal
	•	Görüntü işleme varsayılan olarak cihaz içinde yapılır.
	•	Fotoğraflar kullanıcı izni olmadıkça asla buluta yüklenmez.
	•	Kullanıcıya “Eğlence amaçlıdır” bildirimi gösterilir.
	•	Privacy Policy ve Terms of Use sunulur.
	•	App Store Privacy Nutrition Label doğru doldurulur.

⸻

13. Monetization

13.1 Subscription Model
	•	Aylık ve yıllık premium paket.
	•	Sınırsız aura taraması.
	•	Uzun aura yorumları.
	•	Aura trendleri ve ek rehber içerikleri.

13.2 Pricing (Region-Based)
	•	Ülkelere göre App Store fiyatları otomatik belirlenir.
	•	TR / US / EU için farklı fiyat bandı uygulanır.

13.3 Upsell Points
	•	Sonuç ekranında premium CTA.
	•	Günlük ücretsiz kullanım sınırı sonrası paywall.
	•	Gelişmiş açıklamalar için premium sayfası.

⸻

14. Credit System (Optional Alternative to Subscription)

14.1 Logic
	•	1 kredi = 1 aura taraması.
	•	Kullanıcı kredi paketleri satın alabilir.
	•	Premium kullanıcılar kredi tüketmez.

14.2 Firebase Implementation Outline
	•	credits/{userId}
	•	transactions/{transactionId}
	•	Cloud Function ile kredi düşümü.

⸻

15. Analytics

15.1 Events
	•	app_open
	•	onboarding_completed
	•	camera_permission_granted
	•	scan_started
	•	scan_completed (primaryColorId)
	•	result_saved
	•	result_shared
	•	purchase_success
	•	purchase_failed

15.2 Metrics
	•	Günlük tarama sayısı.
	•	7-30 günlük kullanıcı tutma oranı.
	•	Premium dönüşüm oranı.
	•	Ülkelere göre kullanım istatistikleri.

⸻

16. UI/UX Structure

16.1 Screens
	•	Onboarding
	•	Permission
	•	Camera
	•	Result
	•	History
	•	History Detail
	•	Settings
	•	Country & Language
	•	Subscription / Paywall

16.2 Design Style
	•	Koyu tema.
	•	Aura halkaları için renk gradyanları.
	•	Modern minimalist tipografi.
	•	Animasyonlu geçişler.

⸻

17. Testing Plan

17.1 Unit Tests
	•	AuraEngine:
	•	HSV dönüşümü
	•	k-means sonuç doğruluğu
	•	Renk eşleme
	•	Localization: tüm dillerde key doğrulama.

17.2 UI Tests
	•	Onboarding → Camera → Result akışı.
	•	History ekranının yüklenmesi.
	•	Dil değişim testi.

17.3 Beta Testing (TestFlight)
	•	Kamera performansı.
	•	Farklı ışık koşulları.
	•	Farklı cihaz boyutları.

⸻

18. Release Plan
	•	App Store Connect profil ayarları.
	•	Ekran görüntüleri (tüm diller).
	•	App icon, splash screen.
	•	Privacy Policy linkleri.
	•	Build upload → TestFlight → Review → Release.

⸻

19. Roadmap

Phase 1 – MVP (6 Hafta)
	•	Kamera modülü
	•	AuraEngine (heuristic)
	•	Sonuç ekranı
	•	History
	•	EN + TR destek

Phase 2 – Expansion (6 Hafta)
	•	5 ülkeye göre aura içerikleri
	•	Premium abonelik
	•	Paywall
	•	Trend grafiği

Phase 3 – ML Upgrade (8+ Hafta)
	•	Veri seti oluşturma
	•	ML eğitim
	•	CoreML entegrasyonu

⸻

20. Sprint Plan (4 Sprints)

Sprint 1
	•	Proje kurulumu
	•	Kamera + Vision yüz tespiti

Sprint 2
	•	AuraEngine geliştirme
	•	Renk eşleme
	•	Result ekranı

Sprint 3
	•	Localization
	•	History
	•	Settings

Sprint 4
	•	Paywall
	•	IAP
	•	App Store hazırlık
