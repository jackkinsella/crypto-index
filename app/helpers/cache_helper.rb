module CacheHelper
  def action_cache(param_names = [])
    controller = params[:controller]
    action = params[:action]

    param_part = Array(param_names).map(&:to_s).sort.inject('') { |part, key|
      part + "/#{key}=#{params[key]}"
    }

    Rails.cache.fetch("#{controller}##{action}#{param_part}") {
      yield
    }
  end
end
