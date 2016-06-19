namespace :exchanges do

  desc "Import AMEX, NASDAQ & NYSE stock data from CSV into the DB"
  task :import_all, [:csv_files] => [:environment] do |_task, args|
    DEFAULT_CSV_FILES = [
      "app/exchanges/AMEX.csv",
      "app/exchanges/NASDAQ.csv",
      "app/exchanges/NYSE.csv"
    ].freeze
    csv_files = args[:csv_files] || DEFAULT_CSV_FILES
    csv_files.each do |exchange|
      Rake::Task["exchanges:import_stock"].reenable
      Rake::Task["exchanges:import_stock"].invoke(exchange)
    end
  end

  desc "Import specified stock data from CSV into the DB"
  task :import_stock, [:file_path] => [:environment] do |_task, args|
    file_path = args[:file_path]
    raise "File does not exist under #{file_path}" unless File.exist?(file_path)

    rows = []
    CSV.foreach(file_path, headers: true) do |row|
      begin
        rows << row
      rescue => ex
        puts "Error: #{ex.message}"
      end
    end

    success = []
    failure = []
    rows.each do |row|
      begin
        stock = Stock.create!(
          symbol: row[0],
          name: row[1],
          last_sale: (row[2].to_f * 100).to_i,
          market_cap: row[3],
          ipo_year: row[4],
          sector: row[5],
          industry: row[6],
          summary_quote: row[7]
        )
        success << stock
      rescue => ex
        failure << row
        puts "Error occured while processing file: #{file_path}"
        puts "Failed to create stock with symbol '#{row[0]}' and company name '#{row[1]}'"
        puts "Cause of error: #{ex.message}"
      end
    end

    puts "\n"
    puts "***************** REPORT *****************"
    puts "File processed: #{file_path}"
    puts "Total number of stocks: #{rows.size}"
    puts "Stocks successfully created: #{success.size}"
    puts "Stocks failed to be created: #{failure.size}"
    puts "******************************************"
    puts "\n"
  end

end
