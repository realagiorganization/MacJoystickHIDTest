# Development Plan – Mac Joystick HID Test

## Objectives
- Keep the native macOS HID test app buildable and runnable in Xcode while preserving current functionality.
- Maintain the static docs/GitHub Pages preview that explains the tool.
- Add automated BDD coverage for principal user-facing flows.
- Provide CI that runs BDD checks and records a console demo via VHS.

## External Dependencies
- **Xcode with macOS SDK + IOKit.framework** – required to build and run the Objective-C HID tester.
- **HID-compatible joystick/controller hardware (USB)** – needed for end-to-end manual validation of axis/button reads.
- **Node.js 20+ and npm** – used for the BDD suite tooling.
- **Playwright (Chromium)** – headless browser for exercising the docs/landing page in tests.
- **@cucumber/cucumber** – BDD runner for feature files.
- **charmbracelet/vhs** – records terminal/UI interactions into GIFs for documentation.
- **GitHub Actions runners (ubuntu-latest)** – CI environment executing tests and VHS capture.

## Workflow
1. **Setup**
   - Install Xcode + command line tools; confirm `IOKit.framework` is available.
   - Install Node.js 20+, run `npm ci`, and install Playwright browsers (`npx playwright install --with-deps chromium`).
2. **Build & Run (mac app)**
   - Open `JoystickHIDTest.xcodeproj` in Xcode.
   - Build and run target `JoystickHIDTest` on macOS with a connected joystick.
3. **Docs / Web Preview**
   - Open `docs/index.html` directly or serve the `docs/` folder (`npx http-server docs -p 4173`).
   - Verify hero, diagnostics, and preview sections render.
4. **Testing (BDD)**
   - Execute `npm run test:bdd` to run Playwright + Cucumber scenarios against the docs page.
   - Add new scenarios by editing `tests/features/*.feature` and matching step definitions in `tests/steps/`.
5. **CI/CD**
   - GitHub Actions workflow `bdd.yml` runs on push/PR to execute the BDD suite.
   - Workflow `vhs.yml` replays the terminal tape to regenerate the GIF demo and upload it as an artifact.
6. **Release & Documentation**
   - Update README badges and GIF demos after CI runs.
   - Record any new assumptions or environment expectations in `docs/ASSUMPTIONS.md`.

## Milestones
- **M1: BDD foundation** – npm toolchain + initial feature coverage for hero and content sections.
- **M2: CI green** – bdd.yml stable on push/PR; VHS capture automated.
- **M3: Native validation** – joystick hardware smoke test performed manually on macOS (outside CI) with outcomes noted in docs.

## Risks & Mitigations
- **No joystick hardware in CI** – limit automated tests to the docs/UX; keep hardware checks manual and documented.
- **Playwright browser weight** – install Chromium only to keep CI faster.
- **VHS drift** – regenerate GIF via `vhs.yml` whenever CLI output changes.
