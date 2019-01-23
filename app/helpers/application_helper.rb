module ApplicationHelper
  include RenderHelper
  include SessionHelper
  include StorageHelper
  include CacheHelper
  include FontHelper

  attr_reader :page

  def obfuscate(text, reveal: 5)
    reveal = [reveal, text.length / 3].min
    text[0...reveal] + ' **** ' + text[-reveal..-1]
  end
end
