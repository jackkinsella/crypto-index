module RuboCop
  module Cop
    module Lint
      class DangerousMethods < Cop
        MSG = '`%<name>s` is considered a dangerous method.'.freeze

        NAMES = [
          :first_or_create,
          :first_or_create!,
          :first_or_initialize,
          :first_or_initialize!,
          :update_attribute
        ].freeze

        def on_send(node)
          name = node.children[1]

          return unless dangerous_method?(name)

          message = MSG % {name: name}
          add_offense(node, location: :selector, message: message)
        end

        private

        def dangerous_method?(name)
          NAMES.include?(name)
        end
      end
    end
  end
end
