module RuboCop
  module Cop
    module Lint
      class MethodSequence < Cop
        MSG = '`%<this_name>s` should come before `%<other_name>s`.'.freeze

        NAMES = [
          :belongs_to,
          :has_one,
          :has_many,
          :validates,
          :validate,
          :alias_attribute,
          :delegate,
          :delegate_missing_to,
          :before_validation,
          :after_validation,
          :before_save,
          :before_create,
          :after_create,
          :after_save,
          :scope
        ].freeze

        def on_send(node)
          name = node.children[1]

          return if inside_method_definition?(node)

          if correct_sequence?(name)
            self.current_index = NAMES.index(name) if NAMES.include?(name)
            return
          end

          message = MSG % {this_name: name, other_name: NAMES[current_index]}
          add_offense(node, location: :selector, message: message)
        end

        private

        attr_accessor :current_index

        def correct_sequence?(name)
          current_index.nil? ||
          NAMES.index(name).nil? ||
          NAMES.index(name) >= current_index
        end

        def inside_method_definition?(node)
          node.ancestors.any? { |ancestor| ancestor.source.start_with?('def') }
        end
      end
    end
  end
end
