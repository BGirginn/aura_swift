# App Store Assets & Metadata Plan

## 1. Visual Assets
| Device | Orientation | Count | Notes |
| --- | --- | --- | --- |
| 6.7\" (Pro Max) | Portrait | 5 | Camera scan, multi-mode selector, quiz, result/story screen, history trend |
| 6.1\" (Pro) | Portrait | 3 | Settings localization, notifications toggle, share sheet |
| 5.5\" (legacy) | Portrait | 3 | Simplified UI shots (enable “debug aura preview” for consistent colors) |
| iPad Pro 12.9 (optional) | Landscape | 2 | Only if we ship universal layout |

**Capture Tips**
- Enable `Debug/Test Mode` to inject consistent aura colors.
- Use `xcrun simctl io booted screenshot --mask` for clean outputs.
- Apply subtle drop shadows + background gradient in Figma template (`/Design/app_store_template.fig` placeholder).

## 2. App Preview Video (optional)
- 15–30 seconds, 1080x1920.
- Storyboard: (1) Mode selection, (2) camera scan animation, (3) result storytelling, (4) history trend & notifications.
- Record via Simulator + edit in Final Cut / CapCut with captions in EN + localized text layers.

## 3. Metadata Checklist
- **Name:** Aura Color Finder
- **Subtitle:** Discover your aura via AI & personality quiz
- **Keywords:** aura, color, energy, chakra, personality test, meditation
- **Description Outline:**
  1. Hook paragraph (“Capture your aura in seconds…”)
  2. Feature bullets (Camera Scan, Photo Analysis, Quiz Mode, History & Stories, Localization)
  3. Privacy statement (on-device processing, no uploads)
  4. Upcoming roadmap teaser (CoreML upgrade, widgets)
- **Promotional Text:** “Try the new multi-mode aura scan with story-style insights!”
- **Support URL:** https://auracolor.app/support
- **Marketing URL:** https://auracolor.app
- **Privacy URL:** https://auracolor.app/privacy

## 4. Localization Strategy
- Translate metadata for TR, DE, FR, UK (en-GB). 
- Use professional translator or localized copy deck (sheet columns: key, EN-US, EN-GB, TR, DE, FR).
- Update screenshot captions per locale (use single Figma file with per-language pages).

## 5. Submission Assets Folder
```
Design/
 └── AppStore/
     ├── screenshots-67/
     │   ├── 01-camera.png
     │   ├── 02-mode-selection.png
     │   └── ...
     ├── screenshots-61/
     ├── screenshots-55/
     ├── preview-video.mp4
     └── metadata.json  (App Store Connect API format)
```

## 6. Outstanding Tasks
- [ ] Capture baseline screenshots once UI polish locked.
- [ ] Prepare localized text snippets.
- [ ] Decide if App Preview video needed for launch 1.0.

