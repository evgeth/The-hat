.PHONY: help screenshots screenshots-setup screenshots-fast screenshots-open

# Force UTF-8 so CocoaPods doesn't choke on default ASCII-8BIT locale.
export LANG := en_US.UTF-8
export LC_ALL := en_US.UTF-8

help:
	@echo "Targets:"
	@echo "  make screenshots-setup   One-time setup: install gems, configure UI test target, install pods"
	@echo "  make screenshots         Run full screenshot generation (all devices, all locales)"
	@echo "  make screenshots-fast    Re-snapshot using already-built tests (skip recompile)"
	@echo "  make screenshots-open    Open the screenshots output folder in Finder"

screenshots-setup:
	@command -v bundle >/dev/null || { echo 'bundler missing. Run: gem install bundler'; exit 1; }
	bundle install
	bundle exec ruby scripts/setup_ui_test_target.rb
	bundle exec pod install

screenshots: screenshots-setup
	bundle exec fastlane screenshots
	bundle exec ruby scripts/build_screenshot_index.rb

screenshots-fast:
	bundle exec fastlane screenshots_fast
	bundle exec ruby scripts/build_screenshot_index.rb

screenshots-open:
	open fastlane/screenshots/index.html
