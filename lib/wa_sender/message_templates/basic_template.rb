# frozen_string_literal: true

class BasicTemplate
  def execute(term)
    public_send("#{term}_payment")
  end

  def form_message_data(account_data)
    invoices = account_data.last

    if invoices.size > 1
      group_invoices_data(invoices)
    else
      { debt: invoices.first[:total],
        invoice: invoices.first[:code],
        overdue_days: count_overdue_days(invoices.first[:invoice_date]),
        link_to_locate: "https://locate.positrace.com/invoices/#{invoices.first[:id]}",
        account: invoices.first[:account] }
    end
  end

  def due_payment
    DuePayment.new
  end

  def advance_payment
    AdvancePayment.new
  end

  def overdue_payment
    OverduePayment.new
  end

  private

  def group_invoices_data(invoices)
    debt_storage = 0

    invoices.each do |invoice|
      debt_storage += invoice[:total][1...-4].sub(',', '').to_f
      next unless invoice == invoices.last

      return {
        debt: "$#{debt_storage.round(2)} MXN",
        invoice: invoices.size.to_s,
        overdue_days: count_overdue_days(invoice[:invoice_date]),
        link_to_locate: 'https://locate.positrace.com/accounts/',   # several invoices link ?
        account: invoice[:account] }
    end
  end

  def count_overdue_days(invoice_date)
    (DateTime.now.to_date - Date.strptime(invoice_date, '%m/%d/%Y')).to_i.to_s
  end
end
