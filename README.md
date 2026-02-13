# DevOps Demo — Flutter Android + GitHub Actions

A minimal, beginner-friendly repository that demonstrates **Mobile CI (Continuous Integration)** from start to finish. Push code, watch a pipeline run, and download a ready-to-install Android debug APK — all automated.

---

## Table of Contents

1. [What this repo demonstrates](#1-what-this-repo-demonstrates)
2. [DevOps & CI/CD for Mobile (in plain English)](#2-devops--cicd-for-mobile-in-plain-english)
3. [How the pipeline works (mental model)](#3-how-the-pipeline-works-mental-model)
4. [What the CI pipeline does (step-by-step)](#4-what-the-ci-pipeline-does-step-by-step)
5. [Local run](#5-local-run)
6. [Run the same checks locally (match CI)](#6-run-the-same-checks-locally-match-ci)
7. [Where to find the APK artifact in GitHub Actions](#7-where-to-find-the-apk-artifact-in-github-actions)
8. [Common failures & quick fixes](#8-common-failures--quick-fixes)
9. [Next steps (optional)](#9-next-steps-optional)

---

## 1. What this repo demonstrates

This repository contains:

- A **default Flutter counter app** (the simplest possible Android app).
- A **GitHub Actions CI pipeline** (`.github/workflows/ci.yml`) that automatically checks code quality, runs tests, builds a debug APK, and uploads it as a downloadable **artifact** (a file produced by the pipeline that you can download and install on a device or emulator).

The goal is to show you that code can be automatically verified and compiled every time someone pushes a change — no manual steps required.

---

## 2. DevOps & CI/CD for Mobile (in plain English)

### What is DevOps?

DevOps is a set of practices that brings together software **development** (writing code) and **operations** (building, testing, deploying). For mobile teams, DevOps means:

- **Repeatable builds** — every build is produced the same way, on the same kind of machine, so you never hear "but it works on my laptop."
- **Fast feedback** — you know within minutes whether your change broke something.
- **Fewer surprises** — problems are caught early, not the night before a release.

### CI vs. CD

| Term | What it means | What it looks like here |
|------|--------------|------------------------|
| **CI — Continuous Integration** | Every code change is automatically checked (formatting, analysis, tests) and compiled into a build. | Our pipeline runs format checks, static analysis, unit tests, and produces a debug APK. |
| **CD — Continuous Delivery / Deployment** | The verified build is automatically delivered to testers or published to an app store. | *Out of scope for this demo.* Teams would extend CI to upload to the Play Store or a testing distribution service. |

**This repo focuses on CI and basic artifact delivery** (you can download the APK from GitHub Actions). It does not publish to the Play Store.

---

## 3. How the pipeline works (mental model)

A **pipeline** is a sequence of automated steps that run every time a specific event happens in your repository.

```
Trigger → Job → Steps (gates) → Artifacts → Results
```

| Concept | Meaning | Where you see it |
|---------|---------|-----------------|
| **Trigger** | The event that starts the pipeline (a push, a pull request, or a manual click). | The `on:` section at the top of `ci.yml`. |
| **Job** | A group of steps that run on a single virtual machine (called a **runner**). | `jobs: build:` in `ci.yml`. Our pipeline has one job running on `ubuntu-latest`. |
| **Step** | One action inside a job (e.g., "run tests"). Steps run in order. | Each `- name:` entry under `steps:`. |
| **Gate** | A step that must pass before the next step runs. If a gate fails, the pipeline stops. | Format → Analyze → Test → Build. A failure at any gate stops the pipeline. |
| **Artifact** | A file produced by the pipeline that you can download afterward. | The debug APK uploaded in the last step. |
| **Logs** | Real-time text output from every step. You can click any step in GitHub Actions to read its log. | The "Actions" tab on your GitHub repository. |
| **Pass / Fail** | A green check (✓) means all gates passed. A red X (✗) means at least one gate failed. | Shown next to your commit or pull request on GitHub. |

---

## 4. What the CI pipeline does (step-by-step)

The pipeline runs these **quality gates** in order. If any gate fails, the pipeline stops immediately — later gates do not run.

### Gate 1 — Fetch dependencies

```
flutter pub get
```

- **What it does:** Downloads all the packages your app needs (listed in `pubspec.yaml`).
- **Why it matters:** Without dependencies, nothing else can run.
- **Typical failure:** A package name is misspelled, a version constraint is impossible to resolve, or `pubspec.yaml` has a syntax error.

### Gate 2 — Formatting check

```
dart format --output=none --set-exit-if-changed .
```

- **What it does:** Checks that every Dart file matches the standard Dart formatting style. It does **not** change any files — it only reports whether changes are needed.
- **Why it matters:** Consistent formatting makes code reviews faster and avoids noise in diffs.
- **Typical failure:** A developer saved a file without running the formatter. The log will list the files that need formatting.

### Gate 3 — Static analysis

```
flutter analyze --fatal-infos
```

- **What it does:** Scans all Dart code for errors, warnings, and style issues defined in `analysis_options.yaml`.
- **Why it matters:** Catches bugs (unused variables, type mismatches, missing imports) before anyone runs the app.
- **Typical failure:** An unused import, a variable that is never read, or a type that does not match.

### Gate 4 — Unit tests

```
flutter test
```

- **What it does:** Runs every test file in the `test/` directory. The default test checks that the counter starts at 0 and increments to 1 when the "+" button is tapped.
- **Why it matters:** Tests prove that your code behaves correctly. If someone accidentally breaks the counter logic, this gate catches it.
- **Typical failure:** An `expect(...)` assertion does not match the actual value.

### Gate 5 — Build debug APK

```
flutter build apk --debug
```

- **What it does:** Compiles the Flutter app + Android native code into a debug APK file at `build/app/outputs/flutter-apk/app-debug.apk`.
- **Why it matters:** Proves the entire project compiles successfully on a clean machine — not just on your laptop.
- **Typical failure:** A Gradle configuration error, a missing Android SDK component, or a Dart compile error that the analyzer did not catch.

### Gate 6 — Upload APK artifact

```yaml
uses: actions/upload-artifact@v4
with:
  name: app-debug-apk
  path: build/app/outputs/flutter-apk/app-debug.apk
```

- **What it does:** Takes the APK file and attaches it to the GitHub Actions run so anyone can download it.
- **Why it matters:** Team members, testers, or reviewers can grab the APK directly from GitHub without setting up a development environment.
- **Typical failure:** The build step failed, so the APK file does not exist.

---

## 5. Local run

Prerequisites: Flutter SDK installed and an Android emulator running (or a physical device connected via USB with developer mode enabled).

```bash
# 1. Clone the repository
git clone <your-repo-url>
cd cicd_demo

# 2. Install dependencies
flutter pub get

# 3. Run the app on your connected device / emulator
flutter run
```

You should see the default Flutter counter app. Tap the **+** button to increment the counter.

---

## 6. Run the same checks locally (match CI)

You can run the exact same gates that CI runs. Open a terminal in the project root:

```bash
# Gate 1 – Fetch dependencies
flutter pub get

# Gate 2 – Formatting check (fails if any file needs formatting)
dart format --output=none --set-exit-if-changed .

# Gate 3 – Static analysis (fails on any issue)
flutter analyze --fatal-infos

# Gate 4 – Unit tests
flutter test

# Gate 5 – Build debug APK
flutter build apk --debug
```

If every command exits with code 0 (no errors), your code will also pass CI.

> **Tip:** If the formatting check fails, run `dart format .` (without `--set-exit-if-changed`) to auto-fix all files, then commit the changes.

---

## 7. Where to find the APK artifact in GitHub Actions

1. Go to your repository on GitHub.
2. Click the **Actions** tab.
3. Click on the latest workflow run (it will be named something like "Flutter Android CI").
4. Scroll to the bottom of the run summary page.
5. Under the **Artifacts** section, you will see **app-debug-apk**.
6. Click it to download a `.zip` file containing `app-debug.apk`.

An **artifact** in CI/CD is simply a file (or set of files) that the pipeline produces and saves for you. In this case, it is the compiled Android app.

---

## 8. Common failures & quick fixes

### Formatting failure

```
Changed lib/main.dart
```

**What happened:** One or more files are not formatted according to `dart format`.

**Fix:** Run `dart format .` locally, then commit and push. The file(s) listed in the error output are the ones that need formatting.

---

### Analysis error

```
info • Unused import • lib/main.dart:2:8 • unused_import
```

**What happened:** The analyzer found an issue. Common examples: unused imports, undefined variables, type mismatches.

**Fix:** Open the file and line number mentioned in the error. Remove the unused import, fix the typo, or correct the type. Run `flutter analyze` locally to verify the fix.

---

### Test failure

```
Expected: exactly one matching widget
  Actual: _TextWidgetFinder:<zero widgets with text "0">
```

**What happened:** A test assertion did not match. The app's behavior differs from what the test expects.

**Fix:** Decide whether the app code or the test is wrong. If you changed the app intentionally (e.g., the counter now starts at 1), update the test to match. Run `flutter test` locally to confirm.

---

### Android / Gradle build failure

```
FAILURE: Build failed with an exception.
```

**What happened:** The Android build system (Gradle) could not compile the project. Common causes:

- **Mismatched SDK versions** — check `android/app/build.gradle` for `compileSdk`, `minSdk`, and `targetSdk`.
- **Dependency conflict** — a plugin requires a different Kotlin or Gradle version.
- **Missing Android SDK component** — the CI runner may need a specific SDK version.

**Fix:** Read the error message carefully — Gradle usually tells you exactly what is wrong. Fix the configuration in `android/app/build.gradle` or `android/build.gradle`, then push again.

---

## 9. Next steps (optional)

This demo intentionally keeps things simple. In a real project, teams typically extend CI with:

- **UI / integration tests on an emulator** — run the app on a virtual device in CI and execute automated tap-and-verify tests. This catches visual regressions and navigation bugs that unit tests cannot.
- **Signed release builds** — use a keystore to produce a release APK or App Bundle suitable for the Play Store. This involves securely storing signing keys as CI secrets.
- **Automated distribution** — after a successful build, automatically upload the APK to a testing service (e.g., Firebase App Distribution) or directly to the Play Store.
- **iOS builds** — add a macOS runner to build the iOS version alongside Android.

These are all natural extensions of what you see here, but they require additional configuration, accounts, and (in some cases) paid services — so they are out of scope for this beginner demo.

---

**That's it!** You now have a working Mobile CI pipeline. Push a commit, watch the pipeline run, and download your APK. Happy building!
