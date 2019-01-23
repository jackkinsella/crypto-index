module FontHelper
  def preload_font_tag(font_name, type:)
    asset_root = Rails.application.config.settings.asset_root
    content_tag :link, nil,
      href: "#{asset_root}/fonts/#{font_name}",
      crossorigin: 'anonymous', rel: 'preload', as: 'font', type: type
  end
end
