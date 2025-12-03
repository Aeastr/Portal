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
3. Make your changes. Follow the [Development Setup](#development-setup) and [Coding Guidelines](#coding-guidelines).

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
2. **Create PR**: Open pull requests to `dev` for review
3. **Merge to `dev`**: After approval, merge triggers automatic dev snapshot creation
4. **Release to `main`**: When ready for an official release, create a PR from `dev` → `main`
5. **Create release**: After merging to `main`, manually create the GitHub release

**Branch Protection**: Direct pushes to `main` are not allowed. All changes must go through pull requests, even for maintainers.

### Development Snapshots

Portal automatically creates development snapshots when PRs are merged to the `dev` branch:

#### Dev Snapshots (Automated Testing Versions)
- **Trigger**: Automatically when **any PR** is merged to the `dev` branch
- **Purpose**: Create testable snapshots for testing changes before official releases
- **Format**: `dev-YYYYMMDD-HHMMSS-sha` (e.g., `dev-20250113-143022-a1b2c3d`)
- **How it works**: GitHub Actions automatically creates a pre-release snapshot on every merge
- **Use case**: Testing changes in consuming apps via Swift Package Manager

**Example snapshot usage in Package.swift:**
```swift
.package(url: "https://github.com/Aeastr/Portal", exact: "dev-20250113-143022-a1b2c3d")
```

**Note**: Snapshots are marked as pre-releases and include a warning that they're for testing only. The workflow will comment on your PR with the snapshot tag and usage instructions.

### Official Releases

Official releases are created **manually** by maintainers:

#### Creating an Official Release
1. **Prepare the release**: Ensure all desired changes are merged to `dev` and tested
2. **Create release PR**: `dev` → `main` with a descriptive title
3. **Review and merge**: After CI passes and review approval
4. **Create GitHub release**: Manually create a release from the GitHub UI:
   - Go to the [Releases page](https://github.com/Aeastr/Portal/releases)
   - Click "Draft a new release"
   - Choose a tag (e.g., `4.3.0`) or create a new one
   - Write release notes describing changes
   - Publish the release

**Release notes should include:**
- What's new (features, enhancements)
- Breaking changes (if any)
- Bug fixes
- Migration guide (if needed)

### Standard Pull Requests

For regular PRs (bug fixes, features):

1. Link your PR to the relevant issue (if there is one)
2. Describe what you've changed and why
3. Keep PRs focused—one feature or fix per PR
4. Ensure all examples build and run without warnings or errors
5. Be responsive to review feedback

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

### SwiftLint Workflow
- Runs SwiftLint on all Swift files
- Checks code style and formatting
- Must pass before merging

### Dev Snapshot Workflow (dev branch only)
- Triggers automatically on PR merge to `dev`
- Creates timestamped pre-release snapshot
- Generates changelog from commits since last snapshot
- Comments on PR with snapshot tag and usage instructions
- Marks as pre-release with testing-only warning

Please address any CI failures before merging. The build and test badges in the README show current status.

### Failed Snapshot Recovery

If a dev snapshot creation fails after a PR is merged, the workflow includes automatic cleanup. However, if manual intervention is needed:

1. **Check the workflow logs**
   - Go to Actions → Failed workflow run
   - Review error messages and identify the issue

2. **If the tag was created but snapshot failed**
   - The workflow automatically attempts to clean up the tag
   - If cleanup failed, manually delete: `git push --delete origin dev-YYYYMMDD-HHMMSS-sha`
   - Delete the local tag if present: `git tag -d dev-YYYYMMDD-HHMMSS-sha`

3. **Common recovery scenarios**
   - **Snapshot failed**: The workflow will retry automatically
   - **Tag already exists**: Should not happen due to timestamp uniqueness, but can be manually deleted if needed
   - **Comment failed**: Snapshot is still created, just not commented on PR

The workflow will notify you on the PR if anything fails, with links to the relevant logs.

### Hotfix Releases

For urgent bug fixes that need to bypass the normal dev → main workflow:

1. **Create hotfix branch from main**:
   ```bash
   git checkout main
   git pull origin main
   git checkout -b hotfix/4.2.3
   ```

2. **Make your fix** and commit it

3. **Create PR**: `hotfix/4.2.3` → `main`
   - **Title**: Descriptive title (e.g., "Fix critical crash in PortalLayerView")
   - **Description**: Explain the critical fix and impact

4. **After merge**:
   - Manually create a GitHub release with the new version tag
   - Sync the fix back to dev:
     ```bash
     git checkout dev
     git merge main
     git push origin dev
     ```

**Version Selection for Hotfixes**:
- Increment **PATCH** version only (e.g., 4.2.2 → 4.2.3)
- For multiple hotfixes: Continue incrementing patch (4.2.3 → 4.2.4)

### Edge Case Handling

**Wrong PR merged to main**:
1. **Revert the merge commit** on main:
   ```bash
   git revert -m 1 <merge-commit-sha>
   git push origin main
   ```
2. **Fix the issue** on dev and create a new release PR

**Wrong PR merged to dev**:
1. **If snapshot was created**: Snapshots are pre-releases and won't affect production
2. **Revert the merge** if needed:
   ```bash
   git checkout dev
   git revert -m 1 <merge-commit-sha>
   git push origin dev
   ```
3. **Optional**: Delete the unwanted snapshot tag if desired:
   ```bash
   git push --delete origin dev-YYYYMMDD-HHMMSS-sha
   ```

**Modifying a release after publishing**:
- **Published releases**:
  - Edit the release notes on GitHub (doesn't require new tag)
  - For code changes: Create a new hotfix release with incremented version
  - **Never** delete or modify published tags/releases with code changes

**Multiple releases on same day**:
- Each release must have a unique version number
- Increment patch version for each subsequent release (4.2.2 → 4.2.3 → 4.2.4)
- Dev snapshots automatically use timestamps to ensure uniqueness

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
