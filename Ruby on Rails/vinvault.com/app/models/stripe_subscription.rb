class StripeSubscription < ActiveRecord::Base
  has_one :user, as: :subscription

  def update_plan(role)
    DT.p 'Updating plan'
    user.role_ids = []
    user.add_role(role.name)
    unless customer_id.nil?
      customer = Stripe::Customer.retrieve(customer_id)
      customer.update_subscription(:plan => role.name)
    end
    true
  rescue Stripe::StripeError => e
    AppLog.log 'Stripe Error: ' + e.message
    user.errors.add :base, "Unable to update your subscription. #{e.message}."
    false
  end

  def update_subscription(params)
    stripe_token = params[:stripe_token]
    coupon = params[:coupon]
    DT.p 'Updating subscription'
    return if user.email.include?(ENV['ADMIN_EMAIL'])
    return if user.email.include?('@example.com') #and not Rails.env.production?
    if customer_id.nil?
      unless stripe_token.present?
        raise "Stripe token not present. Can't create account."
      end
      if coupon.blank?
        customer = Stripe::Customer.create(
            :email => user.email,
            :description => user.name,
            :card => stripe_token,
            :plan => user.roles.first.name
        )
      else
        customer = Stripe::Customer.create(
            :email => user.email,
            :description => user.name,
            :card => stripe_token,
            :plan => user.roles.first.name,
            :coupon => coupon
        )
      end
    else
      customer = Stripe::Customer.retrieve(customer_id)
      if stripe_token.present?
        customer.card = stripe_token
      end
      customer.email = user.email
      customer.description = user.name
      customer.save
    end
    self.last_4_digits = customer.cards.data.first['last4']
    self.customer_id = customer.id
    true
  rescue Stripe::StripeError => e
    logger.error 'Stripe Error: ' + e.message
    user.errors.add :base, "#{e.message}."
    false
  end

  def cancel_subscription
    unless customer_id.nil?
      customer = Stripe::Customer.retrieve(customer_id)
      unless customer.nil? or customer.respond_to?('deleted')
        #if !customer.subscription.nil? && customer.subscription.status == 'active'
        customer.cancel_subscription
        UserMailer.cancellation_email(user).deliver
        #end
      end
    end
  rescue Stripe::StripeError => e
    logger.error 'Stripe Error: ' + e.message
    user.errors.add :base, "Unable to cancel your subscription. #{e.message}."
    false
  end

  def self.user_from_customer_id(customer_id)
    record = where(customer_id: customer_id).first
    return record.user unless record.nil?
    nil
  end

  def update_stripe
    customer = Stripe::Customer.retrieve(customer_id)
    if stripe_token.present?
      customer.card = stripe_token
    end
    customer.email = user.email
    customer.description = user.name
    customer.save

    self.last_4_digits = customer.cards.data.first['last4']
    self.customer_id = customer.id
    save
  end

end
