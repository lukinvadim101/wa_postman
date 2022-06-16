class OverduePayment < BasicTemplate
  def handler(message_data)
    template = 'En PosiTrace, nos preocupamos por brindarle el mejor servicio posbile. Es por eso que le invitamos a ponerse al día con sus obligaciones ingresando en el siguiente enlace [INSERT PAYMENT OPTIONS/LINK TO LOCATE]. De esta forma podrá evitar el bloqueo de su plataforma debido a la falta de pago de su factura [CODE] por un total de [TOTAL].'

    template.sub! '[INSERT PAYMENT OPTIONS/LINK TO LOCATE]', message_data[:link_to_locate].to_s
    template.sub! '[CODE]', message_data[:invoice].to_s
    template.sub! '[TOTAL]', message_data[:debt].to_s

    template
  end
end
