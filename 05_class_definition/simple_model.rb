# 次の仕様を満たす、SimpleModelモジュールを作成してください
#
# 1. include されたクラスがattr_accessorを使用すると、以下の追加動作を行う
#   1. 作成したアクセサのreaderメソッドは、通常通りの動作を行う
#   2. 作成したアクセサのwriterメソッドは、通常に加え以下の動作を行う
#     1. 何らかの方法で、writerメソッドを利用した値の書き込み履歴を記憶する
#     2. いずれかのwriterメソッド経由で更新をした履歴がある場合、 `true` を返すメソッド `changed?` を作成する <- この日本語は解釈が複数あるのでよくない
#        修正案: いずれかのwriterメソッド経由で更新した履歴があるかをbooleanで返す、`changed?` メソッドを作成する
#     3. 個別のwriterメソッド経由で更新した履歴を取得できるメソッド、 `ATTR_changed?` を作成する
#       1. 例として、`attr_accessor :name, :desc`　とした時、このオブジェクトに対して `obj.name = 'hoge` という操作を行ったとする
#       2. `obj.name_changed?` は `true` を返すが、 `obj.desc_changed?` は `false` を返す
#       3. 参考として、この時 `obj.changed?` は `true` を返す
# 2. initializeメソッドはハッシュを受け取り、attr_accessorで作成したアトリビュートと同名のキーがあれば、自動でインスタンス変数に記録する
#   1. ただし、この動作をwriterメソッドの履歴に残してはいけない
# 3. 履歴がある場合、すべての操作履歴を放棄し、値も初期状態に戻す `restore!` メソッドを作成する
module SimpleModel

  def self.included(klass)
    # TODO: オリジナルの attr_accessor を利用してもっとスマートに書けるかも？
    klass.define_singleton_method(:attr_accessor) do |*args|
      class_eval do
        def changed?
          @changed&.values&.any? || false
        end
      end

      args.each do |name|
        # getter
        klass.define_method(name) do
          instance_variable_get("@#{name}")
        end
        # setter
        klass.define_method("#{name}=") do |value|
          instance_variable_set("@#{name}", value)
          @changed = {} if @changed.nil?
          @changed[name] = true
        end
        # changed?
        klass.define_method("#{name}_changed?") do
          @changed&.[](name) || false
        end
      end
    end
  end

  def initialize(attributes)
    @initial_attributes = attributes
    attributes.each do |key, value|
      # TODO もうちょいスマートに attr_accessor で指定されたかチェックしたい
      instance_variable_set("@#{key}", value) if methods.include?("#{key}=".to_sym)
    end
  end

  def restore!
    @changed = {}
    @initial_attributes.each do |key, value|
      instance_variable_set("@#{key}", value) if methods.include?("#{key}=".to_sym)
    end
  end
end
