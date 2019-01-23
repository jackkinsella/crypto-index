module StorageHelper
  def storage
    @_storage ||= begin
      local_storage =
        Class.new(Hash) {
          def initialize(session)
            super(nil)

            @session = session

            (@session.delete(:local) || {}).each do |key, value|
              original_set(key, value)
            end
          end

          alias_method :original_set, :'[]='
          def []=(key, value)
            super

            (@session[:local] ||= {})[key] = value
          end
        }.new(session)

      OpenStruct.new(
        local: local_storage
      )
    end
  end
end
