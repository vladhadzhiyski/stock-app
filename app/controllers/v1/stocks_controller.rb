module V1
  class StocksController < ApplicationController

    def create

    end

    def index
      stocks = Stock.all
      render json: { stocks: stocks }
    end

    def show
    end

  end
end
