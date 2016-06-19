require "spec_helper"

describe "exchanges:import_stock" do
  let(:file_path) { "tmp/nasdaq-sample.csv" }
  let(:stock_rows) do
    [
      ["Symbol", "Name", "LastSale", "MarketCap", "IPOyear", "Sector", "industry", "Summary Quote", nil],
      ["GRPN", "Groupon, Inc.", "3.25", "$1.89B", "2011", "Technology", "Advertising", "http://www.nasdaq.com/symbol/grpn", nil],
      ["TSLA", "Tesla Motors, Inc.", "217.7", "$29.16B", "2010", "Capital Goods", "Auto Manufacturing", "http://www.nasdaq.com/symbol/tsla", nil]
    ]
  end

  before(:all) do
    StockApi::Application.load_tasks
  end

  def create_and_read_csv_stock_data_file(specified_file_path = nil)
    if specified_file_path.nil?
      # write csv file
      specified_file_path = file_path
      CSV.open(file_path, 'w') do |csv|
        stock_rows.each do |row|
          csv << row
        end
      end
    end

    rows = []
    # read csv file
    CSV.foreach(specified_file_path, headers: true) do |row|
      rows << row
    end
    return rows
  end

  describe "exchanges:import_stock" do
    let(:task_name) { "exchanges:import_stock" }

    describe "failures" do
      it "raises an error if the specified CSV file does not exist" do
        non_existent_file = "tmp/does-not-exist.csv"
        expect do
          Rake::Task[task_name].invoke(non_existent_file)
        end.to raise_error("File does not exist under #{non_existent_file}")
      end
    end

    describe "success" do
      it "creates & reads a CSV file with 2 stock data entries and successfully persist them" do
        rows = create_and_read_csv_stock_data_file
        grpn_stock = stock_rows[1]
        expected_symbol = grpn_stock[0]
        expected_name = grpn_stock[1]
        expected_last_sale = (grpn_stock[2].to_f * 100).to_i
        expected_market_cap = grpn_stock[3]
        expected_ipo_year = grpn_stock[4]
        expected_sector = grpn_stock[5]
        expected_industry = grpn_stock[6]
        expected_summary_quote = grpn_stock[7]
        expected_stock_size = rows.size

        expect do
          Rake::Task[task_name].reenable
          Rake::Task[task_name].invoke(file_path)
        end.to change{Stock.count}.by(expected_stock_size)

        stock = Stock.find_by(symbol: expected_symbol)
        expect(stock.symbol).to eq(expected_symbol)
        expect(stock.name).to eq(expected_name)
        expect(stock.last_sale).to eq(expected_last_sale)
        expect(stock.market_cap).to eq(expected_market_cap)
        expect(stock.ipo_year).to eq(expected_ipo_year)
        expect(stock.sector).to eq(expected_sector)
        expect(stock.industry).to eq(expected_industry)
        expect(stock.summary_quote).to eq(expected_summary_quote)
        File.delete(file_path) if File.exist?(file_path)
      end
    end

  end

  describe "exchanges:import_all" do
    let(:task_name) { "exchanges:import_all" }

    it "uses the default CSV files to import and persist its stock data" do
      expected_stock_size = 0
      [
        "app/exchanges/AMEX.csv",
        "app/exchanges/NASDAQ.csv",
        "app/exchanges/NYSE.csv"
      ].each do |default_csv_file|
        rows = create_and_read_csv_stock_data_file(default_csv_file)
        expected_stock_size += rows.size
      end

      expect do
        Rake::Task[task_name].reenable
        Rake::Task[task_name].invoke
      end.to change{Stock.count}.by(expected_stock_size)
    end

    it "uses the specified CSV file to import and persist its stock data" do
      rows = create_and_read_csv_stock_data_file
      expected_stock_size = rows.size

      expect do
        Rake::Task[task_name].reenable
        Rake::Task[task_name].invoke([csv_file_path])
      end.to change{Stock.count}.by(expected_stock_size)
    end
  end

end
