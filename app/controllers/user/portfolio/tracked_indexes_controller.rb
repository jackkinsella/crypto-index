class User::Portfolio::TrackedIndexesController < ApplicationController
  before_action :require_authentication, :require_level_1

  def index
    @indexes = current_user.holdings.present? ? [Index.m10] : []
  end
end
