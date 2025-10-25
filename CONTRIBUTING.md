# Contributing to Portal

First off, thank you for your interest in contributing to Portal! 🙏 Your help makes Portal better for everyone.

## Code of Conduct

Please read and follow the [Code of Conduct](./CODE_OF_CONDUCT.md). I’m committed to fostering an open, welcoming, and respectful community.

## How to Report Issues

Before opening a new issue, search existing issues to avoid duplicates. When filing a bug report, please include:
- Portal version (e.g. `0.1.2`) and your Swift/Xcode versions  
- Target platform (iOS 15.0+), device or simulator  
- A concise description of the problem and steps to reproduce  
- Minimal code snippet or sample project demonstrating the issue  
- Any relevant console logs or screenshots

## How to Propose Features

If you have an idea for a new feature or enhancement:
1. Search existing feature requests or discuss in Slack/Discord.  
2. Open a new “Feature Request” issue with:
   - A clear problem statement  
   - Proposed API or usage sketch  
   - Any design or UX considerations  

## Getting Started

1. Fork the repo and clone locally:
   ```bash
   git clone https://github.com/aeastr/Portal.git
   cd Portal
   ```
2. Create a feature branch:
   ```bash
   git checkout -b feat/my-new-feature
   ```
3. Make y changes. Follow the [Development Setup](#development-setup) and [Coding Guidelines](#coding-guidelines).

4. Commit with a clear message:
   ```
   feat: add `.portalFade` animation option
   ```

5. Push and open a Pull Request against `main`.

## Development Setup

### Prerequisites

- Xcode 15 or later
- iOS 15.0+ deployment target
- SwiftLint for code style checking:
  ```bash
  brew install swiftlint
  ```

### Initial Setup

1. Clone & open `Portal.xcodeproj` or use the Swift Package in your own project
2. Set up Git hooks for automatic code checking:
   ```bash
   ./Scripts/setup-hooks.sh
   ```

## Coding Guidelines

- Use idiomatic Swift & SwiftUI conventions
- Structure code for readability and reuse
- Keep public APIs minimal and well-documented
- If you introduce new API, add samples under `Sources/Portal/Examples`
- Follow SwiftLint rules (see `.swiftlint.yml`)
- Write unit tests _where applicable_

### Code Style

This project uses SwiftLint to maintain consistent code style. Run checks with:
```bash
# Check all files
swiftlint lint --config .swiftlint.yml

# Auto-fix issues where possible
swiftlint autocorrect --config .swiftlint.yml

# Or use the provided script
./Scripts/run-swiftlint.sh
```

SwiftLint runs automatically:
- **Pre-commit**: Checks staged Swift files
- **CI/CD**: On all pushes and pull requests
- **Xcode**: Can be integrated as a build phase

### Constants & Best Practices

- Use `PortalConstants` for all timing and configuration values
- Don't hardcode delays or durations
- All files must end with a newline
- Example:
  ```swift
  // ✅ Good
  DispatchQueue.main.asyncAfter(deadline: .now() + PortalConstants.animationDelay)

  // ❌ Bad
  DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
  ```

## Running Tests

Portal also includes example targets rather than formal unit tests. To verify functionality:
1. Open the `Portal.xcodeproj` in Xcode  
2. Run each demo (SheetExample, NavigationExample, DifferExample) on a simulator or device  
3. Ensure transitions behave as expected

## Documentation

- **Wiki**: [View Wiki](https://github.com/Aeastr/Portal/wiki), update installation, usage, and examples sections as needed  
- Add or update screenshots/GIFs under `docs/images` with descriptive filenames

## Pull Request Process

### Branch Strategy

Portal uses a protected `main` branch with the following workflow:

1. **Work on the `dev` branch** for all changes
2. **Create PR**: `dev` → `main` when ready for release
3. **PR Format for Releases**:
   - **Title**: Version number (e.g., `4.3.0` or `Release 4.3.0`)
   - **Description**: Full changelog/release notes (this becomes the GitHub release notes)
4. **Merge to `main`**: Automatically creates a GitHub release with the version tag

**Branch Protection**: Direct pushes to `main` are not allowed. All changes must go through pull requests, even for maintainers.

### Standard Pull Requests

For non-release PRs (bug fixes, features):

1. Link your PR to the relevant issue (if there is one)
2. Describe what you've changed and why
3. Keep PRs focused—one feature or fix per PR
4. Ensure all examples build and run without warnings or errors
5. Be responsive to review feedback

### Release Pull Requests

When creating a release PR (`dev` → `main`):

**Example PR Title:**
```
4.3.0
```
or
```
Release 4.3.0
```

**Example PR Description:**
```markdown
## What's New
- Added support for custom transition curves
- Improved performance for large view hierarchies
- Fixed memory leak in portal cleanup

## Breaking Changes
- Renamed `PortalTransition` to `PortalEffect` for clarity

## Bug Fixes
- Fixed issue where portals wouldn't work in nested NavigationStacks
- Resolved crash on iOS 17.0 when using `.portalDestination` in sheets
```

Upon merge, this will automatically:
- Create git tag `4.3.0`
- Create GitHub draft release with your description as release notes
- Generate automatic changelog from commits since last release

**Note**: Releases are created as **drafts by default** for safety. You need to manually publish them:
1. Go to the [Releases page](https://github.com/Aeastr/Portal/releases)
2. Find your draft release
3. Review the release notes
4. Click "Publish release"

To change this behavior and auto-publish releases, edit `.github/workflows/release.yml` and set `DRAFT_RELEASE: 'false'`

## Continuous Integration

All PRs are validated by CI with separate workflows:

### Build Workflow
- Builds the package for testing
- Uploads build artifacts for test reuse
- Must pass before tests run

### Test Workflow
- Runs after successful build
- Downloads build artifacts (no rebuild)
- Executes all unit tests with 5-minute timeout
- Uploads test results

### Release Workflow (main branch only)
- Triggers on PR merge to `main`
- Extracts version from PR title
- Creates git tag and GitHub release
- Uses PR description as release notes

Please address any CI failures before merging. The build and test badges in the README show current status.

## Troubleshooting

Common issues and solutions:

### SwiftLint Issues

- **SwiftLint not found**: Install with `brew install swiftlint`
- **Hooks not running**: Run `./Scripts/setup-hooks.sh` to configure Git hooks
- **CI failing**: Run `./Scripts/run-swiftlint.sh` locally first to catch issues
- **Auto-fix not working**: Run `swiftlint --fix --config .swiftlint.yml` manually
- **Too many violations**: Focus on errors first (red), warnings (yellow) can be addressed later

### Build Issues

- **Swift version mismatch**: Ensure you're using Xcode 15+ with Swift 5.9+
- **Package resolution failed**: Try `swift package resolve` or clean build folder
- **Missing dependencies**: Run `swift package update`

### Git Hook Issues

- **Permission denied**: Run `chmod +x .githooks/*` and `chmod +x Scripts/*.sh`
- **Hooks not executing**: Check that `git config core.hooksPath` points to `.githooks`
- **Commit blocked by linting**: Use `git commit --no-verify` to bypass (use sparingly!)

### Testing Issues

- **Examples not building**: Ensure `#if DEBUG` wrapper is present
- **Portal transitions not working**: Check that `PortalContainer` wraps your root view
- **Memory leaks**: Weak references are intentional for portal cleanup

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for helping make Portal even more magical! 🚀
