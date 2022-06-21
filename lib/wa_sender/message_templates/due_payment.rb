class DuePayment < BasicTemplate
  def generate(message_data)
    template = 'PoiTrace te informa que tu factura [CODE] por un total de [TOTAL] presenta [INSERT OVERDUE TIME IN DAYS] días de vencimiento. Puedes ponerte al día con tu factura haciendo clic aquí [INSERT PAYMENT OPTIONS/LINK TO LOCATE]. Si ya efectuaste el pago, has caso omiso a este mensaje.'

    template.sub! '[CODE]', message_data[:invoice]
    template.sub! '[TOTAL]', message_data[:debt]
    template.sub! '[INSERT OVERDUE TIME IN DAYS]', message_data[:overdue_days]
    template.sub! '[INSERT PAYMENT OPTIONS/LINK TO LOCATE]', message_data[:link_to_locate]

    template
  end
end
