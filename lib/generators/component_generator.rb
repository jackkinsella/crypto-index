class ComponentGenerator < Rails::Generators::Base
  argument :component, type: :string, banner: '[path/]name'

  desc 'Create a new React component in app/javascript/components.'
  def create_component
    create_file "#{path}#{name.camelize}.jsx", jsx
    create_file "#{path}#{name.camelize}.scss", scss

    scss_path = 'app/views/layouts/application.scss'
    line = File.readlines("#{Rails.root}/#{scss_path}")[5..-1].find { |item|
      import_directive < item
    }
    insert_into_file scss_path, import_directive, before: line
  end

  private

  def path
    "app/javascript/components/#{component[0...-name.size]}"
  end

  def name
    component[/[^\/]+\z/]
  end

  def jsx
    <<~JSX
      import React from 'react'
      import PropTypes from 'prop-types'

      export default class #{name.camelize} extends React.Component {
        static propTypes = {
          children: PropTypes.node,
          helpers: PropTypes.object.isRequired
        }

        static defaultProps = {}

        render() {
          return (
            <div className="#{name.underscore.dasherize}" />
          )
        }
      }
    JSX
  end

  def scss
    <<~SCSS
      .#{name.underscore.dasherize} {}
    SCSS
  end

  def import_directive
    <<~SCSS
      @import "../../#{path[4..-1]}#{name.camelize}";
    SCSS
  end
end
