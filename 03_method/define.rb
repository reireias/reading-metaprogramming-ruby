# Q1.
# 次の動作をする A1 class を実装する
# - "//" を返す "//"メソッドが存在すること
class A1
  define_method('//') do
    '//'
  end
end

# Q2.
# 次の動作をする A2 class を実装する
# - 1. "SmartHR Dev Team"と返すdev_teamメソッドが存在すること
# - 2. initializeに渡した配列に含まれる値に対して、"hoge_" をprefixを付与したメソッドが存在すること
# - 2で定義するメソッドは下記とする
#   - 受け取った引数の回数分、メソッド名を繰り返した文字列を返すこと
#   - 引数がnilの場合は、dev_teamメソッドを呼ぶこと
class A2
  def initialize(methods)
    methods.each do |method|
      name = "hoge_#{method}"
      self.class.send(:define_method, name) do |count|
        return dev_team if count.nil?

        name * count
      end
    end
  end

  def dev_team
    'SmartHR Dev Team'
  end
end

# Q3.
# 次の動作をする OriginalAccessor モジュール を実装する
# - OriginalAccessorモジュールはincludeされたときのみ、my_attr_accessorメソッドを定義すること
# - my_attr_accessorはgetter/setterに加えて、boolean値を代入した際のみ真偽値判定を行うaccessorと同名の?メソッドができること
module OriginalAccessor
  self.class.send(:define_method, :my_attr_accessor) do |name|
    # getter
    define_method(name) { instance_variable_get("@#{name}") }

    # setter
    define_method("#{name}=") do |value|
      if value.is_a?(TrueClass) || value.is_a?(FalseClass)
        # booleanを代入した時に name? を定義
        self.class.send(:define_method, "#{name}?") do
          instance_variable_get("@#{name}")
        end
      elsif methods.include?("#{name}?".to_sym)
        # boolean以外を代入したときに、name? があれば削除
        self.class.send(:remove_method, "#{name}?")
      end

      instance_variable_set("@#{name}", value)
    end
  end
end
