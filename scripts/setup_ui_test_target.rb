#!/usr/bin/env ruby
# frozen_string_literal: true

# Idempotently configures the Xcode project for screenshot generation:
#   - Adds thehat/Services/ScreenshotMode.swift to the main "thehat" target
#   - Creates a "thehatUITests" UI test target if missing
#   - Adds the test source files to that target
#   - Wires the test target into the "thehat" shared scheme

require 'xcodeproj'

PROJECT_PATH = File.expand_path('../thehat.xcodeproj', __dir__)
MAIN_TARGET_NAME = 'thehat'
UI_TEST_TARGET_NAME = 'thehatUITests'
UI_TEST_DIR = File.expand_path('../thehatUITests', __dir__)
SCREENSHOT_MODE_PATH = 'thehat/Services/ScreenshotMode.swift'
TEAM_ID = 'DSQACR84TV'
DEPLOYMENT_TARGET = '12.0'
SWIFT_VERSION = '5.0'

project = Xcodeproj::Project.open(PROJECT_PATH)
main_target = project.targets.find { |t| t.name == MAIN_TARGET_NAME }
abort "Main target #{MAIN_TARGET_NAME.inspect} not found" unless main_target

# --- 1. Ensure ScreenshotMode.swift is part of the main target ---------------
def ensure_file_in_target(project, target, path_relative_to_project, group_path)
  abs_path = File.expand_path("../#{path_relative_to_project}", __dir__)
  unless File.exist?(abs_path)
    abort "Missing source file: #{abs_path}"
  end

  already_compiled = target.source_build_phase.files_references.any? do |ref|
    ref && ref.real_path.to_s == abs_path
  end
  return if already_compiled

  # Walk to the existing group without mutating any source_tree settings —
  # changing them on an existing group breaks sibling files that resolve paths
  # relative to <group>.
  group = project.main_group
  group_path.each do |segment|
    found = group.children.find { |c| c.is_a?(Xcodeproj::Project::Object::PBXGroup) && (c.path == segment || c.name == segment) }
    if found.nil?
      found = group.new_group(segment, segment)
    end
    group = found
  end

  existing_ref = group.files.find { |f| f.real_path.to_s == abs_path }
  file_ref = existing_ref || group.new_file(File.basename(abs_path))
  target.add_file_references([file_ref])
  puts "  + Added #{path_relative_to_project} to #{target.name}"
end

ensure_file_in_target(project, main_target, SCREENSHOT_MODE_PATH, %w[thehat Services])

# --- 2. Create the UI test target (idempotent) -------------------------------
ui_test_target = project.targets.find { |t| t.name == UI_TEST_TARGET_NAME }

if ui_test_target.nil?
  puts "* Creating UI test target #{UI_TEST_TARGET_NAME}"
  ui_test_target = project.new_target(
    :ui_test_bundle,
    UI_TEST_TARGET_NAME,
    :ios,
    DEPLOYMENT_TARGET,
    nil,
    :swift
  )
  ui_test_target.add_dependency(main_target)
end

ui_test_target.build_configurations.each do |config|
  settings = config.build_settings
  settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  settings['TEST_TARGET_NAME'] = MAIN_TARGET_NAME
  settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.dpfbop.#{UI_TEST_TARGET_NAME}"
  settings['DEVELOPMENT_TEAM'] = TEAM_ID
  settings['SWIFT_VERSION'] = SWIFT_VERSION
  settings['IPHONEOS_DEPLOYMENT_TARGET'] = DEPLOYMENT_TARGET
  settings['INFOPLIST_FILE'] = "#{UI_TEST_TARGET_NAME}/Info.plist"
  settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks', '@loader_path/Frameworks']
  settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'YES'
  settings['CODE_SIGN_STYLE'] = 'Automatic'
  settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  settings['SDKROOT'] = 'iphoneos'
  settings['WRAPPER_EXTENSION'] = 'xctest'
end

# --- 3. Add test source files to the UI test target --------------------------
ui_test_group = project.main_group.find_subpath(UI_TEST_TARGET_NAME, true)
ui_test_group.set_source_tree('SOURCE_ROOT')
ui_test_group.set_path(UI_TEST_TARGET_NAME)

%w[ScreenshotTests.swift SnapshotHelper.swift].each do |filename|
  abs_path = File.join(UI_TEST_DIR, filename)
  abort "Missing UI test source: #{abs_path}" unless File.exist?(abs_path)

  already_compiled = ui_test_target.source_build_phase.files_references.any? do |ref|
    ref && ref.real_path.to_s == abs_path
  end
  next if already_compiled

  ref = ui_test_group.files.find { |f| f.real_path.to_s == abs_path } || ui_test_group.new_file(abs_path)
  ui_test_target.add_file_references([ref])
  puts "  + Added #{filename} to #{UI_TEST_TARGET_NAME}"
end

# Ensure Info.plist file ref exists in the group (not compiled, just referenced)
info_plist_path = File.join(UI_TEST_DIR, 'Info.plist')
unless ui_test_group.files.any? { |f| f.real_path.to_s == info_plist_path }
  ui_test_group.new_file(info_plist_path)
  puts "  + Linked Info.plist into #{UI_TEST_TARGET_NAME} group"
end

project.save

# --- 4. Wire the test target into the shared "thehat" scheme -----------------
scheme_path = File.join(PROJECT_PATH, 'xcshareddata', 'xcschemes', "#{MAIN_TARGET_NAME}.xcscheme")
if File.exist?(scheme_path)
  scheme = Xcodeproj::XCScheme.new(scheme_path)
  testables = scheme.test_action.testables
  already_added = testables.any? { |t| t.buildable_references.any? { |b| b.target_name == UI_TEST_TARGET_NAME } }
  unless already_added
    testable = Xcodeproj::XCScheme::TestAction::TestableReference.new(ui_test_target)
    scheme.test_action.add_testable(testable)
    scheme.save_as(PROJECT_PATH, MAIN_TARGET_NAME, true)
    puts "* Added #{UI_TEST_TARGET_NAME} to #{MAIN_TARGET_NAME} scheme"
  end
else
  warn "Shared scheme not found at #{scheme_path} — you may need to add the UI test target to the scheme manually."
end

puts "Project setup complete."
