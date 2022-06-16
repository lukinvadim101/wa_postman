class AdvancePayment < BasicTemplate
  def handler(message_data)
    template = '[ACCOUNT], PosiTrace te informa que la fecha para realizar el pago de tu cuenta, está próxima a vencer. Ingresa en el siguiente link [INSERT LINK TO LOCATE] y consulta cuál es el estado de tus facturas.'

    template.sub! '[ACCOUNT]', message_data[:account].to_s
    template.sub! '[INSERT LINK TO LOCATE]', message_data[:link_to_locate].to_s

    template
  end
end
