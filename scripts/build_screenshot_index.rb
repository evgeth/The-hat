#!/usr/bin/env ruby
# frozen_string_literal: true

# Builds a self-contained HTML index of every PNG under fastlane/screenshots,
# regardless of device name. Works around fastlane's hardcoded device list
# (which silently drops anything newer than iPhone 15 Pro Max) and avoids
# AJAX/fetch so it loads cleanly from a file:// URL.

require 'cgi'
require 'pathname'

ROOT = Pathname.new(File.expand_path('../fastlane/screenshots', __dir__))
abort "No screenshots directory at #{ROOT}" unless ROOT.directory?

# Group: locale => { device => [{name:, file:}] }
by_locale = {}
ROOT.glob('*/*.png').sort.each do |path|
  locale = path.parent.basename.to_s
  filename = path.basename.to_s
  # Conventional fastlane naming: "<Device Name>-<Screenshot Name>.png"
  match = filename.match(/\A(.+?)-(\d+-.+?)\.png\z/) || filename.match(/\A(.+?)-(.+?)\.png\z/)
  device, screen = match ? [match[1], match[2]] : ['Unknown', filename.sub('.png', '')]

  by_locale[locale] ||= {}
  by_locale[locale][device] ||= []
  by_locale[locale][device] << { name: screen, file: "#{locale}/#{filename}" }
end

if by_locale.empty?
  warn "No screenshots found under #{ROOT}. Run `make screenshots` first."
  exit 1
end

html = +<<~HTML
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <title>The Hat — App Store Screenshots</title>
    <style>
      body { font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", sans-serif; margin: 24px; color: #222; background: #fafafa; }
      h1 { margin: 0 0 8px; }
      h2 { margin-top: 32px; padding-bottom: 4px; border-bottom: 1px solid #ddd; }
      h3 { margin: 24px 0 12px; color: #555; font-weight: 500; }
      .device-row { display: flex; flex-wrap: wrap; gap: 16px; }
      .shot { background: #fff; border: 1px solid #e5e5e5; border-radius: 8px; padding: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
      .shot img { display: block; height: 480px; width: auto; border-radius: 4px; }
      .shot .label { margin-top: 8px; font-size: 13px; color: #666; text-align: center; }
      .meta { color: #888; font-size: 14px; }
    </style>
  </head>
  <body>
    <h1>The Hat — App Store Screenshots</h1>
    <p class="meta">Generated #{Time.now.strftime('%Y-%m-%d %H:%M')} · #{by_locale.values.flat_map(&:values).flatten.size} images</p>
HTML

by_locale.sort.each do |locale, devices|
  html << "    <h2>#{CGI.escapeHTML(locale)}</h2>\n"
  devices.sort.each do |device, shots|
    html << "    <h3>#{CGI.escapeHTML(device)}</h3>\n"
    html << "    <div class=\"device-row\">\n"
    shots.sort_by { |s| s[:name] }.each do |shot|
      html << "      <div class=\"shot\"><img src=\"#{CGI.escapeHTML(shot[:file])}\" alt=\"#{CGI.escapeHTML(shot[:name])}\"><div class=\"label\">#{CGI.escapeHTML(shot[:name])}</div></div>\n"
    end
    html << "    </div>\n"
  end
end

html << "  </body>\n</html>\n"

out = ROOT.join('index.html')
out.write(html)
puts "Wrote #{out}"
