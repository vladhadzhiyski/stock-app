require "spec_helper"
require "rails_helper"

describe StocksController do
  fixtures(:stocks)

  let(:groupon_stock) { stocks(:groupon_stock) }

  describe "#index" do
    it "returns default number of stocks, where default is 10" do
      expected_stock_size = Stock.all.size
      expected_response = {
        "symbol" => groupon_stock.symbol,
        "name" => groupon_stock.name
      }
      get :index
      expect(json_body.size).to eq(expected_stock_size)
      groupon_stock_response = json_body.find{|stock| stock["symbol"] == groupon_stock.symbol}
      expect(groupon_stock_response).to include(expected_response)
    end

    context "when pagination params are provided" do
      it "returns only 1 stock result when limit is 1" do
        params = { limit: 1 }
        get :index, params
        expect(json_body.size).to eq(1)
      end

      it "returns only 1 stock result when limit is 1 and offset is 1" do
        params = { limit: 1, offset: 1 }
        get :index, params
        expect(json_body.size).to eq(1)
      end
    end

    context "when search param is provided" do

      context "when stock results are found" do

        let(:low) { "2.92666666" }
        let(:high) { "3.12" }
        let(:open) { "3.10" }
        let(:close) { "3.05" }

        it "returns Groupon stock result if the search term is 'Groupon'" do
          average = (low.to_f + high.to_f + open.to_f + close.to_f) / 4
          average = (average * 100).round / 100.0

          mock_yahoo_client = double("Yahoo Client Mock")
          expect(YahooFinance::Client).to receive(:new).and_return(mock_yahoo_client)
          mock_yahoo_response = double("Yahoo Data Mock Response", low: low, high: high, open: open, close: close)
          allow(mock_yahoo_client).to receive(:quotes).and_return([mock_yahoo_response])

          expected_stock = {
            "symbol" => groupon_stock.symbol,
            "name" => groupon_stock.name,
            "low" => 2.93,
            "high" => 3.12,
            "open" => 3.10,
            "close" => 3.05,
            "average" => average
          }
          params = { search: "Groupon" }
          get :index, params
          expect(json_body.size).to eq(1)
          groupon_stock_json = json_body.find{|stock| stock["symbol"] == groupon_stock.symbol}
          expect(groupon_stock_json).to include(expected_stock)
        end

        it "returns stock results with average set to when either low, high, open or close is 0" do
          low = "0"
          expected_average = 0

          mock_yahoo_client = double("Yahoo Client Mock")
          expect(YahooFinance::Client).to receive(:new).and_return(mock_yahoo_client)
          mock_yahoo_response = double("Yahoo Data Mock Response", low: low, high: high, open: open, close: close)
          allow(mock_yahoo_client).to receive(:quotes).and_return([mock_yahoo_response])

          expected_stock = {
            "symbol" => groupon_stock.symbol,
            "name" => groupon_stock.name,
            "low" => 0.0,
            "high" => 3.12,
            "open" => 3.10,
            "close" => 3.05,
            "average" => expected_average
          }
          params = { search: "Groupon" }
          get :index, params
          expect(json_body.size).to eq(1)
          groupon_stock_json = json_body.find{|stock| stock["symbol"] == groupon_stock.symbol}
          expect(groupon_stock_json).to include(expected_stock)
        end
      end

      context "when no stock results are found" do
        it "returns empty stock results if the company name with a requested search term does not exist" do
          params = { search: "Nonexistent" }
          get :index, params
          expect(json_body).to eq([])
        end
      end

    end
  end

  describe "#show" do
    it "returns a given stock if stock is found" do
      expected_response = {
        "symbol" => groupon_stock.symbol,
        "name" => groupon_stock.name
      }
      get :show, id: groupon_stock.symbol
      expect(json_body).to include(expected_response)
    end

    it "returns not_found error if stock is not found" do
      non_existent_symbol = 'BADSYMBOL'
      get :show, id: non_existent_symbol
      expect(response.body).to eq("null")
    end
  end

end
