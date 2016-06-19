require "spec_helper"

describe Stock do

  let(:stock) do
    Stock.new(
      symbol: "GRPN",
      name: "Groupon Inc.",
      last_sale: 325,
      market_cap: "$1.89B",
      ipo_year: "2011",
      sector: "Technology",
      industry: "Advertising",
      summary_quote: "http://www.nasdaq.com/symbol/grpn"
    )
  end

  describe "validations" do

    it "persists" do
      expect do
        stock.save!
      end.to_not raise_error
      expect(stock.symbol).to eq("GRPN")
      expect(stock.name).to eq("Groupon Inc.")
      expect(stock.last_sale).to eq(325)
      expect(stock.market_cap).to eq("$1.89B")
      expect(stock.ipo_year).to eq("2011")
      expect(stock.sector).to eq("Technology")
      expect(stock.industry).to eq("Advertising")
      expect(stock.summary_quote).to eq("http://www.nasdaq.com/symbol/grpn")
    end

    context "for required fields" do

      it "raises an error if symbol is missing" do
        stock.symbol = nil
        expect do
          stock.save!
        end.to raise_error("Validation failed: Symbol can't be blank")
      end

      it "raises an error when attempting to create stock with an existing or already taken symbol" do
        expect do
          stock.save!
        end.to_not raise_error

        duplicate_stock = stock.dup
        expect do
          duplicate_stock.save!
        end.to raise_error("Validation failed: Symbol has already been taken")
      end

    end

    context "for non-required fields" do

      [
        "name",
        "last_sale",
        "market_cap",
        "ipo_year",
        "sector",
        "industry",
        "summary_quote"
      ].each do |attribute|
        it "does not raise an error if '#{attribute}' is missing" do
          stock.send("#{attribute}=", nil)
          expect do
            stock.save!
          end.to_not raise_error
        end
      end

    end

  end
end
