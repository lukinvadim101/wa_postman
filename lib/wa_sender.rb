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
    @data = store.data
    @client = MayTapiService.new
    @csv = CsvManager.new
  end

  def execute(term)
    template = BasicTemplate.new.execute(term)

    data.each do |row|
      message_data = template.form_message_data(row)
      message = template.generate(message_data)
      phone = row.last.first[:phone]

      client.send_message(phone, message)
    end
  end

  def find_mailing_errors
    logs = client.get_logs['data']['list']
    path = "#{timestamp}_errors_log"

    logs.each do |row|
      log = row['data']['body']
      next unless log['type'] == 'error'

      message = log['message']
      phone = log['data']['to_number'].to_i

      csv.write(path, phone, message)
    end
  end

  private

  def timestamp
    Time.now.strftime '%Y%m%d%H%M%S'
  end
end

# store = Store.new(CsvManager.new.read('alpha.csv'))
# sender = Sender.new(store)
# sender.execute('due')
# sender.find_mailing_errors
