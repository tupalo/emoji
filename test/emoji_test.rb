# encoding: UTF-8

require File.absolute_path File.dirname(__FILE__) + '/test_helper'

describe Emoji do
  describe "image_url_for_name" do
    it 'should generate url' do
      assert_equal 'http://localhost:3000/cyclone.png', Emoji.image_url_for_name('cyclone')
    end
  end

  describe "image_url_for_unicode_moji" do
    it 'should generate url' do
      assert_equal 'http://localhost:3000/cyclone.png', Emoji.image_url_for_unicode_moji('🌀')
    end
  end

  describe "asset_host" do
    it 'should default to localhost' do
      assert_equal 'http://localhost:3000', Emoji.asset_host
    end

    it 'should be configurable' do
      with_emoji_config(:asset_host, 'emoji') do
        assert_equal 'emoji', Emoji.asset_host
      end
    end
  end

  describe "asset_path" do
    it 'should default to /' do
      assert_equal '/', Emoji.asset_path
    end

    it 'should be configurable' do
      with_emoji_config(:asset_path, '/emoji') do
        assert_equal '/emoji', Emoji.asset_path
      end
    end
  end

  describe "replace_unicode_moji_with_images" do
    it 'should return original string without emoji' do
      assert_equal "foo", Emoji.replace_unicode_moji_with_images('foo')
    end

    it 'should escape html in non html_safe aware strings' do
      replaced_string = Emoji.replace_unicode_moji_with_images('❤<script>')
      assert_equal "<img class=\"emoji\" src=\"http://localhost:3000/heart.png\">&lt;script&gt;", replaced_string
    end

    it 'should replace unicode moji with img tag' do
      base_string = "I ❤ Emoji"
      replaced_string = Emoji.replace_unicode_moji_with_images(base_string)
      assert_equal "I <img class=\"emoji\" src=\"http://localhost:3000/heart.png\"> Emoji", replaced_string
    end

    it 'should handle nil string' do
      assert_equal nil, Emoji.replace_unicode_moji_with_images(nil)
    end

    describe 'with html_safe buffer' do
      it 'should escape non html_safe? strings' do
        string = HtmlSafeString.new('❤<script>')

        replaced_string = string.stub(:html_safe?, false) do
          Emoji.replace_unicode_moji_with_images(string)
        end

        assert_equal "<img class=\"emoji\" src=\"http://localhost:3000/heart.png\">&lt;script&gt;", replaced_string
      end

      it 'should not escape html_safe strings' do
        string = HtmlSafeString.new('❤<a href="harmless">')

        replaced_string = string.stub(:html_safe?, true) do
          Emoji.replace_unicode_moji_with_images(string)
        end
        
        assert_equal "<img class=\"emoji\" src=\"http://localhost:3000/heart.png\"><a href=\"harmless\">", replaced_string
      end

      it 'should always return an html_safe string' do
        string = HtmlSafeString.new('❤')
        replaced_string = string.stub(:html_safe, 'safe_buffer') do
           Emoji.replace_unicode_moji_with_images(string)
        end

        assert_equal "safe_buffer", replaced_string
      end
    end
  end
  
  describe "replace_textual_moji_with_images" do
    it 'should return original string without emoji' do
      assert_equal "foo", Emoji.replace_textual_moji_with_images('foo')
    end
  
    it 'should escape html in non html_safe aware strings' do
      replaced_string = Emoji.replace_textual_moji_with_images(':heart:<script>')
      assert_equal "<img class=\"emoji\" src=\"http://localhost:3000/heart.png\">&lt;script&gt;", replaced_string
    end
  
    it 'should replace unicode moji with img tag' do
      base_string = "I :heart: Emoji"
      replaced_string = Emoji.replace_textual_moji_with_images(base_string)
      assert_equal "I <img class=\"emoji\" src=\"http://localhost:3000/heart.png\"> Emoji", replaced_string
    end
  
    it 'should handle nil string' do
      assert_equal nil, Emoji.replace_textual_moji_with_images(nil)
    end
  
    describe 'with html_safe buffer' do
      it 'should escape non html_safe? strings' do
        string = HtmlSafeString.new(':heart:<script>')
  
        replaced_string = string.stub(:html_safe?, false) do
          Emoji.replace_textual_moji_with_images(string)
        end
  
        assert_equal "<img class=\"emoji\" src=\"http://localhost:3000/heart.png\">&lt;script&gt;", replaced_string
      end
  
      it 'should not escape html_safe strings' do
        string = HtmlSafeString.new(':heart:<a href="harmless">')
  
        replaced_string = string.stub(:html_safe?, true) do
          Emoji.replace_textual_moji_with_images(string)
        end
        
        assert_equal "<img class=\"emoji\" src=\"http://localhost:3000/heart.png\"><a href=\"harmless\">", replaced_string
      end
  
      it 'should always return an html_safe string' do
        string = HtmlSafeString.new(':heart:')
        replaced_string = string.stub(:html_safe, 'safe_buffer') do
           Emoji.replace_textual_moji_with_images(string)
        end
  
        assert_equal "safe_buffer", replaced_string
      end
    end
  end

  class HtmlSafeString < String
    def initialize(*); super; end
    def html_safe; self; end
    def html_safe?; true; end
  end

  def with_emoji_config(name, value)
    original_value = Emoji.send(name)
    begin
      Emoji.send("#{name}=", value)
      yield
    ensure
      Emoji.send("#{name}=", original_value)
    end
  end

end