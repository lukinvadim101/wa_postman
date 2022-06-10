require_relative 'lib/wa_connector'
require_relative 'lib/store'

class Postman
  def initialize
    @wc = WhatsApp_Connector.new
  end

  def sendMessages(data)
    data.each do |row|
      name = row[:name]
      phone = row[:phone]
      message = "It`s a sign, #{name}"

      @wc.formMessage(phone, message)
    end
  end
end

mailing_data = Store.new('data/exm.csv').data
Postman.new.sendMessages(mailing_data)