# Assumptions
- Automated coverage targets the static documentation site in `docs/` because CI cannot access macOS HID hardware.
- Playwright uses Chromium headless and reads the page from the local filesystem (`file://`), which is sufficient for current animations/content.
- Joystick hardware validation remains a manual macOS/Xcode task outside CI until suitable simulators are available.
