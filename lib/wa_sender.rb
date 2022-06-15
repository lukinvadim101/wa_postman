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

    data.each_with_index  do |row, index|
      invoice = row[:code]
      invoice_date = row[:invoice_date]
      debt = row[:total][1...-4].sub(',', '').to_f
      account = row[:account]
      phone = row[:phone]
      link_to_locate = "https://locate.positrace.com/#billing/invoices/{invoice_id}"

      if row != data.last
        account_to_compare = data[index+1][:account]
      else
        account_to_compare = data[index-1][:account]
      end

      if account == account_to_compare
        debt_storage += debt
        invoices_count += 1
        next
      end

      debt = debt_storage.zero? ? debt : debt_storage + debt
      debt = "$#{debt.round(2)} MXN"
      invoice = invoices_count.zero? ? invoice : invoices_count + 1
      overdue_days = count_overdue_days(invoice_date)

      message_data = {
        debt: debt,
        invoice: invoice,
        overdue_days: overdue_days,
        link_to_locate:link_to_locate,
        account:account
      }

      debt_storage = 0
      invoices_count = 0

      message = template.handler(message_data)
      client.send_message(phone, message)
    end
  end

  def count_overdue_days(invoice_date)
    (DateTime.now.to_date - Date.strptime(invoice_date, '%m/%d/%Y')).to_i
  end
end

csv_data = CSVReader.new('data/alpha_csv.csv').csv_data
store = Store.new(csv_data).data
Sender.new(store).execute('advance')