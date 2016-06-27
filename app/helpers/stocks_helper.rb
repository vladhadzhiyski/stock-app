module StocksHelper

  DEFAULT_DATA_FIELDS = [
    :low,
    :high,
    :open,
    :close
  ].freeze

  def lookup_stocks_data(stocks, requested_data_fields = [])
    symbols = stocks.map(&:symbol)
    data_fields = requested_data_fields.empty? ? DEFAULT_DATA_FIELDS : requested_data_fields
    client_data = yahoo_client.quotes(symbols, data_fields)

    stocks_data = {}
    client_data.each_with_index do |data, data_index|
      stock_symbol = symbols[data_index]
      stocks_data[stock_symbol] ||= {}
      data_fields.each_with_index do |field, field_index|
        # Handling special case with the keyboard :open
        if field == :open
          field_value = round_number(data.open)
        else
          field_value = round_number(data.send(field))
        end
        stocks_data[stock_symbol] = {
          field => field_value
        }.merge(stocks_data[stock_symbol])
      end
    end

    return stocks_data
  end

  def round_number(number)
    (number.to_f * 100).round / 100.0
  end

end
