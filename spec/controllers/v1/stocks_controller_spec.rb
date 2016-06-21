require "spec_helper"
require "rails_helper"

module V1
  describe StocksController, type: :controller do
    fixtures(:stocks)
    let(:groupon_stock) { stocks(:groupon_stock) }

    describe "#show" do
      it "returns a given stock if stock is found" do
        expected_response = {
          "symbol" => groupon_stock.symbol,
          "name" => groupon_stock.name,
          "last_sale" => groupon_stock.last_sale,
          "market_cap" => groupon_stock.market_cap,
          "ipo_year" => groupon_stock.ipo_year,
          "sector" => groupon_stock.sector,
          "industry" => groupon_stock.industry,
          "summary_quote" => groupon_stock.summary_quote
        }

        get :show, id: groupon_stock.symbol

        expect(json_body["stock"]).to include expected_response
      end

      it "returns not_found error if stock is not found" do
        non_existent_symbol = 'BADSYMBOL'
        expected_response = {
          "message" => "Stock with symbol #{non_existent_symbol} not found"
        }

        get :show, id: non_existent_symbol

        expect(json_body["error"]).to include expected_response

      end

    end

    describe "#index" do

      it "returns the first 10 (default limit) of stocks" do
        expected_stock_size = Stock.all.size
        expected_response = {
          "symbol" => groupon_stock.symbol,
          "name" => groupon_stock.name,
          "last_sale" => groupon_stock.last_sale,
          "market_cap" => groupon_stock.market_cap,
          "ipo_year" => groupon_stock.ipo_year,
          "sector" => groupon_stock.sector,
          "industry" => groupon_stock.industry,
          "summary_quote" => groupon_stock.summary_quote
        }
        expected_pagination = {
          "meta" => {
            "total" => 2,
            "offset" => 0,
            "limit" => 10
          }
        }

        get :index

        expect(json_body["stocks"].size).to eq(expected_stock_size)
        expect(json_body).to include(expected_pagination)
        groupon_stock_response = json_body["stocks"].find{|stock| stock["symbol"] == groupon_stock.symbol}
        expect(groupon_stock_response).to include expected_response
      end

      context "when pagination params are provided" do
        it "returns only 1 stock result when limit is 1" do
          expected_pagination = {
            "meta" => {
              "total" => 2,
              "offset" => 0,
              "limit" => 1
            }
          }
          params = { limit: 1 }
          get :index, params

          expect(json_body["stocks"].size).to eq(1)
          expect(json_body).to include(expected_pagination)
        end

        it "returns only 1 stock result when limit is 1 and offset is 1" do
          expected_pagination = {
            "meta" => {
              "total" => 2,
              "offset" => 1,
              "limit" => 1
            }
          }
          params = { limit: 1, offset: 1 }
          get :index, params

          expect(json_body["stocks"].size).to eq(1)
          expect(json_body).to include(expected_pagination)
        end
      end

      context "when search param is provided" do
        it "returns Groupon stock result if the search term is 'Groupo'" do
          expected_stock = {
            "symbol" => groupon_stock.symbol,
            "name" => groupon_stock.name,
            "last_sale" => groupon_stock.last_sale,
            "market_cap" => groupon_stock.market_cap,
            "ipo_year" => groupon_stock.ipo_year,
            "sector" => groupon_stock.sector,
            "industry" => groupon_stock.industry,
            "summary_quote" => groupon_stock.summary_quote
          }

          expected_pagination = {
            "meta" => {
              "total" => 1,
              "offset" => 0,
              "limit" => 10
            }
          }
          params = { search: "Groupo" }
          get :index, params

          expect(json_body["stocks"].size).to eq(1)
          expect(json_body).to include(expected_pagination)
          groupon_stock_json = json_body["stocks"].find{|stock| stock["symbol"] == groupon_stock.symbol}
          expect(groupon_stock_json).to include expected_stock
        end

        it "returns empty stock results if the company name with a requested search term does not exist" do
          expected_pagination = {
            "meta" => {
              "total" => 0,
              "offset" => 0,
              "limit" => 10
            }
          }
          params = { search: "Nonexistent" }
          get :index, params

          expect(json_body["stocks"].size).to eq(0)
          expect(json_body).to include(expected_pagination)
        end
      end

    end

  end
end
