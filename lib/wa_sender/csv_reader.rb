require 'csv'

class CSV_reader
  attr_accessor :csv_data

  def initialize(path)
    @csv_data = CSV.read(path, headers: true, header_converters: :symbol).map(&:to_h)
  end
end