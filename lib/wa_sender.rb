require_relative 'wa_sender/mytapi_service'
require_relative 'wa_sender/store'
require_relative 'wa_sender/csv_reader'

class Sender
  def initialize(data)
    @data = data
  end

  def execute(term)
    @account_to_compare = @data[0][:account]
    @debt_sum = 0
    @template = @data[0][:template]

    @data.each do |row|
      invoice_code = row[:code]
      debt = row[:total][1...-4].sub(',', '').to_f
      account = row[:account]

      if account == @account_to_compare && row != @data.last
        count_debt(account, debt)
        next
      end

      debt = @debt_sum.zero? ? debt : @debt_sum

      public_send("#{term}_payment_template", total: debt,  code:  invoice_code)

      # MyTapi_Service.new.sendMessage(phone, @template)
      @debt_sum = 0
    end
  end

  def count_debt(account, row_total)
    @debt_sum += row_total
    @account_to_compare = account
  end

  def count_overdue_days(invoice_date)
    (DateTime.now.to_date - Date.strptime(invoice_date, '%m/%d/%Y')).to_i
  end

  def advance_payment_template(*args)
    @template.sub! '[ACCOUNT]', args[:account]
    @template.sub! '[INSERT LINK TO LOCATE]', args[:link_to_locate]
  end

  def due_payment_template(*args)
    @template.sub! '[CODE]', args[:code]
    @template.sub! '[TOTAL]', args[:total]
    # @template.sub! '[INSERT OVERDUE TIME IN DAYS]', overdue_time_days
    @template.sub! '[INSERT PAYMENT OPTIONS/LINK TO LOCATE]', args[:link_to_locate]
  end

  def overdue_payment_template(*args)
    @template.sub! '[INSERT PAYMENT OPTIONS/LINK TO LOCATE]', args[:link_to_locate]
    @template.sub! '[CODE]', args[:code]
    @template.sub! '[TOTAL]', args[:total]
  end
end

csv_data = CSV_reader.new('data/alpha_csv.csv').csv_data
mailing_data = Store.new(csv_data).data
Sender.new(mailing_data).execute('term')