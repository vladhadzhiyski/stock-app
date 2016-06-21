module V1
  class StocksController < ApplicationController
    include Pagination

    def create
    end

    def index
      if params["search"].present?
        search_term = params["search"]
        total_results = Stock.where('name LIKE ?', "#{search_term}%").count
        pagination = build_pagination(total_results)
        stocks = Stock.where('name LIKE ?', "#{search_term}%").limit(limit).offset(offset).order('name ASC')
      else
        stocks = Stock.limit(limit).offset(offset).order('name ASC')
        pagination = build_pagination(Stock.count)
      end
      render json: { stocks: stocks }.merge(pagination)
    end

    def show
      stock = Stock.find_by(symbol: params[:id])
      if stock.present?
        render json: { stock: stock }
      else
        error_message = {
          message: "Stock with symbol #{params[:id]} not found"
        }
        render json: { error: error_message }
      end
    end

  end
end
