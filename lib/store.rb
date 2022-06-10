require 'csv'

class Store
  attr_accessor :data

  def initialize(path)
    @data = CSV.read(path, headers: true, header_converters: :symbol).map(&:to_h)
  end
end