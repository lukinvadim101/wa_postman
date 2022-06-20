# frozen_string_literal: true

require_relative 'wa_sender/maytapi_service'
require_relative 'wa_sender/store'
require_relative 'wa_sender/csv_manager'
require_relative 'wa_sender/message_templates/basic_template'
require_relative 'wa_sender/message_templates/due_payment'
require_relative 'wa_sender/message_templates/overdue_payment'
require_relative 'wa_sender/message_templates/advance_payment'

class Sender
  attr_accessor :client, :data, :csv

  def initialize(store)
    @data = store
    @client = MayTapiService.new
    @csv = CsvManager.new
  end

  def execute(term)
    template = BasicTemplate.new.execute(term)
    storage = { debt: 0, invoice_count: 0 }

    data.each_with_index do |row, idx|
      debt = row[:total][1...-4].sub(',', '').to_f
      account_to_compare = (row != data.last) ? data[idx + 1][:account] : data[idx - 1][:account]

      if row[:account] == account_to_compare
        storage[:debt] += debt
        storage[:invoice_count] += 1
        next
      end

      message_data = {
        debt: "$#{(storage[:debt].zero? ? debt : storage[:debt] + debt).round(2)} MXN",
        invoice: storage[:invoice_count].zero? ? row[:code] : storage[:invoice_count] + 1,
        overdue_days: count_overdue_days(row[:invoice_date]),
        link_to_locate: form_link_to_locale(storage[:invoice_count], row[:id]),
        account: row[:account]
      }

      storage = { debt: 0, invoice_count: 0 }

      message = template.generate(message_data)
      client.send_message(row[:phone], message)

      # p message
    end
  end

  def find_mailing_errors
    logs = client.get_logs['data']['list']
    path = "#{timestamp}_errors_log"

    logs.each do |row|
      if row['data']['body']['type'] == 'error'
        message = row['data']['body']['message']
        phone = row['data']['body']['data']['to_number'][0..-6]

        csv.write(path, phone, message)
      end
    end
  end

  def count_overdue_days(invoice_date)
    (DateTime.now.to_date - Date.strptime(invoice_date, '%m/%d/%Y')).to_i
  end

  def form_link_to_locale(invoice_count, invoice_code)
    if invoice_count.zero?
      "https://locate.positrace.com/invoices/#{invoice_code}"
    else
      # several invoices link ?
      "https://locate.positrace.com/accounts/"
    end
  end

  def timestamp
    Time.now.strftime '%Y%m%d%H%M%S'
  end
end

store = Store.new(CsvManager.new.read('data/alpha_csv.csv')).data
sender = Sender.new(store)
sender.execute('due')
# sender.find_mailing_errors