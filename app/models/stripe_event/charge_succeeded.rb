# frozen_string_literal: true

class StripeEvent::ChargeSucceeded < StripeEvent
  # def handle; end

  def handle
    charge = event.data.object
    return if charge.invoice
    profile = PaymentProfile.find_by(stripe_customer_id: charge.customer)&.business
    profile ||= Specialist::PaymentSource.find_by(stripe_customer_id: charge.customer)&.specialist
    return unless profile

    profile.invoices.create!(invoice_attrs(charge))
    transfer_invoice(charge) if charge.destination
  end

  # create invoice when transfer money from business to specialist account
  def transfer_invoice(charge)
    stripe_account = StripeAccount.find_by(stripe_id: charge.destination)
    return unless stripe_account
    attrs = invoice_attrs(charge).merge(stripe_event_type: 'payout', stripe_transfer_id: charge.transfer)
    stripe_account.specialist.invoices.create(attrs)
  end

  private

  def invoice_attrs(charge)
    {
      currency: charge.currency,
      price: charge.amount,
      invoice_pdf: charge.receipt_url,
      stripe_charge_id: charge.id,
      date: Time.at(charge.created).utc,
      stripe_customer_id: charge.customer,
      name: charge.description,
      hosted_invoice_url: charge.receipt_url,
      invoice_type: 'project'
    }
  end
end
