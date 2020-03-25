require 'test_helper'
require 'securerandom'
require 'simple_bot'

class TestSimpleBot < MiniTest::Test
  def bot_for_test(&block)
    Class.new(SimpleBot, &block)
  end

  def test_response
    klass = bot_for_test do
      respond 'hello' do
        'Yo'
      end
    end

    assert_equal 'Yo', klass.new.ask('hello')
  end

  def test_no_response
    klass = bot_for_test do
      respond 'yo' do
        'yo'
      end
    end

    assert_nil klass.new.ask("hello")
  end

  def test_global_setting
    klass = bot_for_test do
      setting :name, 'bot'
      respond 'what is your name?' do
        "i'm #{settings.name}"
      end
    end

    assert_equal "i'm bot", klass.new.ask("what is your name?")
  end

  def test_global_setting_random
    code = SecureRandom.hex

    klass = bot_for_test do
      setting :code, code
      respond 'tell me your code' do
        "code is #{settings.code}"
      end
    end

    assert_equal "code is #{code}", klass.new.ask('tell me your code')
  end

  def test_multiple_response
    klass = bot_for_test do
      respond 'hello' do
        'Yo'
      end
      respond 'foo' do
        'bar'
      end
    end

    assert_equal 'Yo', klass.new.ask('hello')
    assert_equal 'bar', klass.new.ask('foo')
  end

  def test_multiple_setting
    klass = bot_for_test do
      setting :name, 'bot'
      setting :hoge, 'HOGE'
      respond 'what is your name?' do
        "i'm #{settings.name} #{settings.hoge}"
      end
    end

    assert_equal "i'm bot HOGE", klass.new.ask("what is your name?")
  end

  def test_instance_method
    klass = bot_for_test do
      setting :name, 'bot'
      respond 'hello' do
        settings.methods.grep(/name/)[0].to_s
      end
    end

    assert_equal 'name', klass.new.ask('hello')
  end
end
