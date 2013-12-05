require 'emoji/version'
require 'json'

# Optionally load EscapeUtils if it's available
begin
  require 'escape_utils'
rescue LoadError
  require 'cgi'
end

require 'emoji/index'

module Emoji
  @asset_host = nil
  @asset_path = nil
  @escaper = defined?(EscapeUtils) ? EscapeUtils : CGI

  def self.asset_host
    @asset_host || 'http://localhost:3000'
  end

  def self.asset_host=(host)
    @asset_host = host
  end

  def self.asset_path
    @asset_path || '/'
  end

  def self.asset_path=(path)
    @asset_path = path
  end

  def self.image_url_for_name(name)
    "#{asset_host}#{ File.join(asset_path, name) }.png"
  end

  def self.image_url_for_unicode_moji(moji)
    emoji = index.find_by_moji(moji)
    image_url_for_name(emoji['name'])
  end

  def self.replace_unicode_moji_with_images(string)
    unless string && string.match(index.unicode_moji_regex)
      return string
    end

    if string.respond_to?(:html_safe?) && string.html_safe?
      safe_string = string
    else
      safe_string = escape_html(string)
    end

    safe_string.gsub!(index.unicode_moji_regex) do |moji|
      %Q{<img class="emoji" src="#{ image_url_for_unicode_moji(moji) }">}
    end
    safe_string = safe_string.html_safe if safe_string.respond_to?(:html_safe)

    safe_string
  end

  def self.escape_html(string)
    @escaper.escape_html(string)
  end

  def self.index
    @index ||= Index.new
  end
end

if defined?(Rails)
  if Rails::VERSION::MAJOR >= 3
    require "emoji/railtie"
  else
    Emoji.asset_host = ActionController::Base.asset_host
    Emoji.asset_path = '/images/emoji'
  end
end
