# frozen_string_literal: true

class Store
  attr_accessor :data

  def initialize(data)
    @data = group_by_account(data)
  end

  def group_by_account(data)
    data.group_by { |invoice| invoice[:account] }
  end
end
