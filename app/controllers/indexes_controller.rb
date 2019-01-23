class IndexesController < ApplicationController
  def index
    @indexes = action_cache {
      Index.order(title: :asc).to_a
    }
  end

  def show
    @index, @currencies, @data = action_cache(:id) {
      index = Index.find_by!(name: params[:id])
      [index, index.components.includes(:currency),
       Charting::Data.for(index).compile]
    }
  end
end
