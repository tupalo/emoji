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
    
    replace_with_images(string) { |safe_string|
      safe_string.gsub!(index.unicode_moji_regex) do |moji|
        %Q{<img class="emoji" src="#{ image_url_for_unicode_moji(moji) }">}
      end
    }
  end
  
  def self.replace_textual_moji_with_images(string)
    unless string && string.match(/:([a-z0-9\+\-_]+):/)
      return string
    end
    
    replace_with_images(string) { |safe_string|      
      safe_string.gsub!(/:([a-z0-9\+\-_]+):/) do |moji|
        if index.find_by_name($1)
          %Q{<img class="emoji" src="#{ image_url_for_name($1) }">} 
        else
          $1
        end
      end
    }
  end

  def self.escape_html(string)
    @escaper.escape_html(string)
  end

  def self.index
    @index ||= Index.new
  end
  
  def self.replace_with_images(string)
    if string.respond_to?(:html_safe?) && string.html_safe?
      safe_string = string
    else
      safe_string = escape_html(string)
    end

    yield safe_string

    safe_string = safe_string.html_safe if safe_string.respond_to?(:html_safe)

    safe_string
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
