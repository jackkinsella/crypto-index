module RenderHelper
  def render_markdown(path)
    @_markdown ||= Redcarpet::Markdown.new(
      Redcarpet::Render::HTML, autolink: true
    )
    @_markdown.render(
      File.read("#{Rails.root}/app/views/#{path}")
    )
  end

  def render_component(path, props = {})
    prepare_assets props[:assets]
    prepare_children props[:children]
    react_component(
      path, sanitize_attributes(props.merge(default_props)),
      prerender: !Rails.env.development?
    )
  end

  def props(file)
    path = lookup_context.find(file + '.yml.erb', [], true).inspect
    props = YAML.safe_load(
      ::ERB.new(File.read(path)).result(binding)
    ).symbolize_keys
    prepare_assets props[:assets]
    props
  end

  private

  def default_props
    instance_variables.reject { |name, _|
      name.to_s.start_with?('@_') || rails_instance_variables.include?(name)
    }.each_with_object({}) { |name, props|
      props[name[1..-1].camelize(:lower)] = instance_variable_get(name)
    }.merge(
      helpers: helpers
    )
  end

  def helpers
    {
      assets: assets,
      paths: paths.merge('current' => request.fullpath)
    }
  end

  def assets
    @_assets = begin
      paths = Dir["#{Rails.root}/app/assets/**/*.*"]
      paths.each_with_object({}) { |full_path, assets|
        path = full_path[/(?<=\/assets\/).*\z/]
        assets[path] = "#{asset_root}/#{path}"
      }
    end
  end

  def paths
    @_paths = begin
      Rails.application.routes.routes.each_with_object({}) { |route, paths|
        paths[route.name&.camelize(:lower)] =
          route.path.spec.to_s[/.*(?=\(\.:format\)\z)/] ||
          route.path.spec.to_s
      }.reject { |name, _| name.blank? || name.start_with?('rails') }.merge(
        current: request.fullpath
      )
    end
  end

  # TODO: Can be removed after refactoring
  def prepare_assets(assets)
    (assets || {}).each do |name, asset|
      if asset.is_a?(Hash)
        (asset || {}).each do |subname, subasset|
          prepare_asset(assets, subasset, name, subname)
        end
      else
        prepare_asset(assets, asset, name)
      end
    end
  end

  # TODO: Can be removed after refactoring
  def prepare_asset(assets, asset, name, subname = nil)
    return if asset.start_with?(asset_root)

    if subname.nil?
      assets[name] = "#{asset_root}/#{asset}"
    else
      assets[name][subname] = "#{asset_root}/#{asset}"
    end
  end

  # TODO: Can be removed after refactoring
  def prepare_children(children)
    (children || {}).each do |name, file|
      next unless file.is_a?(String)
      children[name] = props(file)
    end
  end

  def sanitize_attributes(props)
    props.transform_values { |value|
      if value.is_a?(ApplicationRecord)
        value.sanitized_attributes
      elsif value.respond_to?(:each) && value.first.is_a?(ApplicationRecord)
        value.map(&:sanitized_attributes)
      else
        value
      end
    }
  end

  def asset_root
    Rails.application.config.settings.asset_root
  end

  def rails_instance_variables
    [
      :'@cache_hit',
      :'@marked_for_same_origin_verification',
      :'@output_buffer',
      :'@view_flow',
      :'@view_renderer',
      :'@virtual_path'
    ]
  end
end
