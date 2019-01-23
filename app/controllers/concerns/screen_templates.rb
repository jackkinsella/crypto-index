require 'rails/generators'

module ScreenTemplates
  extend ActiveSupport::Concern

  included do
    if Rails.env.development?
      rescue_from ActionController::UnknownFormat do
        directory = "#{Rails.root}/app/views/templates"
        template = "#{params[:controller]}/#{params[:action]}"
        component = File.basename(params[:controller]).camelize
        path = params[:controller][0...-component.size]

        FileUtils.mkdir_p "#{directory}/#{params[:controller]}"

        File.write(
          "#{directory}/#{template}.html.erb",
          "<%= render_component 'screens/#{path}#{component}' %>\n"
        )

        Rails::Generators.invoke(
          'component', ["screens/#{path}#{component}"]
        )

        render template
      end
    end
  end
end
