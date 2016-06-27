class StocksController < ApplicationController
  include Pagination
  include StocksHelper

  def index
    if params["search"].present?
      search_term = params["search"]
      stocks = Stock.where('name LIKE ?', "#{search_term}%").limit(limit).offset(offset).order('name ASC')
    else
      stocks = Stock.limit(limit).offset(offset).order('name ASC')
    end

    stocks_json = []
    if stocks.present?
      stocks_data = lookup_stocks_data(stocks)
      stocks_data.each do |_symbol, stock_data|
        stock_data[:average] = 0.0
        missing_data_field = false
        DEFAULT_DATA_FIELDS.each do |field|
          missing_data_field = true if stock_data[field].zero?
          stock_data[:average] += round_number(stock_data[field])
        end
        if missing_data_field
          average = 0
        else
          average = stock_data[:average] / DEFAULT_DATA_FIELDS.size
        end
        stock_data[:average] = round_number(average)
      end

      stocks_json = stocks.map do |stock|
        serialized_stock = StockSerializer.new(stock).as_json
        serialized_stock.merge(stocks_data[stock.symbol])
      end
    end

    render json: stocks_json
  end

  def show
    stock = Stock.find_by(symbol: params[:id])
    render json: stock
  end

end
