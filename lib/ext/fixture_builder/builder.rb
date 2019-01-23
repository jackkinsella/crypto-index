# rubocop:disable Metrics/BlockLength, Metrics/MethodLength
module FixtureBuilder
  class Builder
    def dump_tables
      default_date_format = Date::DATE_FORMATS[:default]
      Date::DATE_FORMATS[:default] = Date::DATE_FORMATS[:db]

      begin
        fixtures = tables.inject([]) { |files, table|
          model = table.classify.constantize rescue nil
          if model && model < ActiveRecord::Base
            rows = model.unscoped {
              model.order(:id).collect do |object|
                attributes = object.attributes.select { |name|
                  model.column_names.include?(name)
                }

                attributes.each_with_object({}) do |(name, value), hash|
                  hash[name] = serialized_value_if_needed(model, name, value)
                end
              end
            }
          else
            rows = ActiveRecord::Base.connection.select_all(
              select_sql % {
                table: ActiveRecord::Base.connection.quote_table_name(table)
              }
            )
          end

          next files if rows.empty?

          row_index = '000'
          fixture_data = rows.inject({}) { |hash, record|
            hash.merge(record_name(record, table, row_index) => record)
          }

          write_fixture_file fixture_data, table

          files + [File.basename(fixture_file(table))]
        }
      ensure
        Date::DATE_FORMATS[:default] = default_date_format
      end

      say "Built #{fixtures.to_sentence}"
    end
  end
end
# rubocop:enable Metrics/BlockLength, Metrics/MethodLength
