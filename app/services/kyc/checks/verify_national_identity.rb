module KYC
  module Checks
    class VerifyNationalIdentity < ApplicationAction
      def initialize(machine_readable_zone:)
        @machine_readable_zone = machine_readable_zone
      end

      def execute!
        correct_checksum?
      end

      private

      attr_reader :machine_readable_zone

      def correct_checksum?
        mrz_encoding_for_character = ('A'..'Z').zip((10..35)).
          concat(('0'..'9').zip(0..9)).
          concat([['<', 0]]).to_h

        identity_number.chars.map.with_index { |char, i|
          mrz_encoding_for_character[char] * weights[i]
        }.sum % 10 == checksum
      end

      def weights
        ([7, 3, 1] * 4).first(10)
      end

      def identity_number
        machine_readable_zone[0..8]
      end

      def checksum
        machine_readable_zone[9].to_i
      end
    end
  end
end
