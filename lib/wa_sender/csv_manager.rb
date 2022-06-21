# frozen_string_literal: true

require 'csv'

class CsvManager
  def read(path)
    CSV.read(path, headers: true, header_converters: :symbol).map(&:to_h)
  end

  def write(path, phone, message)
    CSV.open(path, 'a+') do |csv|
      csv << [phone, message]
    end
  end
end
