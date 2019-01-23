class PagesController < ApplicationController
  PAGES = %w[home].freeze

  def show
    raise_404 unless PAGES.include?(params[:page])

    if params[:page] == 'home'
      @page = params[:page]
      @index, @currencies, @data = action_cache(:id) {
        index = Index.m10
        [index, index.components, Charting::Data.for(index).compile]
      }
    end

    render params[:page]
  end

  def about
  end

  def faq
  end

  def terms
  end

  def privacy
  end
end
