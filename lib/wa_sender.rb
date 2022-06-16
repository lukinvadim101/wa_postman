# frozen_string_literal: true

require_relative 'wa_sender/maytapi_service'
require_relative 'wa_sender/store'
require_relative 'wa_sender/csv_reader'
require_relative 'wa_sender/message_templates/basic_template'
require_relative 'wa_sender/message_templates/due_payment'
require_relative 'wa_sender/message_templates/overdue_payment'
require_relative 'wa_sender/message_templates/advance_payment'

class Sender
  attr_accessor :client, :data

  def initialize(store)
    @data = store
    @client = MayTapiService.new
  end

  def execute(term)
    template = BasicTemplate.new.execute(term)
    debt_storage = 0
    invoices_count = 0

    data.each_with_index do |row, index|
      invoice = row[:code]
      debt = row[:total][1...-4].sub(',', '').to_f
      account = row[:account]
      phone = row[:phone]
      link_to_locate = 'https://locate.positrace.com/#billing/invoices/{invoice_id}'

      account_to_compare = if row != data.last
                             data[index + 1][:account]
                           else
                             data[index - 1][:account]
                           end

      if account == account_to_compare
        debt_storage += debt
        invoices_count += 1
        next
      end

      debt = debt_storage.zero? ? debt : debt_storage + debt
      debt = "$#{debt.round(2)} MXN"
      invoice = invoices_count.zero? ? invoice : invoices_count + 1
      overdue_days = count_overdue_days(row[:invoice_date])

      message_data = {
        debt: debt,
        invoice: invoice,
        overdue_days: overdue_days,
        link_to_locate: link_to_locate,
        account: account
      }

      debt_storage = 0
      invoices_count = 0

      message = template.handler(message_data)
      # client.send_message(phone, message)
    end
  end

  def find_errors
    logs = client.get_logs['data']['list']

    logs.each do |key|
      if key['data']['body']['type'] == 'error'
        error_message = key['data']['body']['message']
        # error_code = key['data']['body']['code']
        error_phone_number = key['data']['body']['data']['to_number'][0..-6]

        puts "Error with: #{error_phone_number}; Message: \"#{error_message}\""

        CSV.open("err.csv", "a+") do |csv|
          csv << [error_phone_number, error_message]
        end
      end
    end
  end

  def count_overdue_days(invoice_date)
    (DateTime.now.to_date - Date.strptime(invoice_date, '%m/%d/%Y')).to_i
  end
end

csv_data = CSVReader.new('data/alpha_csv.csv').csv_data
store = Store.new(csv_data).data
# Sender.new(store).execute('advance')

# Sender.new(store).find_errors
