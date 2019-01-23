class AdminController < ApplicationController
  include Protected

  before_action do
    Current.context = :admin
    Current.title = 'Administration'
  end
end
