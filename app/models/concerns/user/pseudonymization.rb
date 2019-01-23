module User::Pseudonymization
  extend ActiveSupport::Concern

  def pseudonymous_id
    @_pseudonymous_id ||= begin
      immutable_traits = {
        id: id,
        created_at: created_at,
        secret: Rails.application.credentials.pseudonymous_id_base
      }

      Digest::SHA256.new.hexdigest(immutable_traits.to_json)
    end
  end

  alias pid pseudonymous_id
end
