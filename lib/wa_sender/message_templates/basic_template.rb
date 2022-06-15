class BasicTemplate
  def execute(term)
    public_send("#{term}_payment")
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
end
