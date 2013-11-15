class User < ActiveRecord::Base
  rolify

  belongs_to :subscription, polymorphic: true

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable

  # Find user for auth token
  scope :for_auth, ->(auth_token) { where(authentication_token: auth_token).first }

  attr_accessor :stripe_token, :coupon
  before_save :update_subscription
  before_save :assign_auth_token
  after_create :send_welcome_email
  before_destroy :cancel_subscription

  def self.add_subscription(sub)
    update_attributes(subscription: sub)
  end


  def self.add_or_update(hash)
    user = User.where(email: hash[:email]).first_or_create
    user.update_attributes(hash)
    puts "Creating/Updating User: #{user.email}" if Settings.verbose
    user
  end

  def update_plan(role)
    if subscription.nil?
      raise 'User: calling update_plan with no subscription'
    else
      subscription.update_plan(role)
    end
  end

  def assign_auth_token
    self.authentication_token = User.authentication_token if !self.authentication_token.present?
  end

  def update_subscription

    if subscription.nil?
      if stripe_token.present?
        subscription = StripeSubscription.create(user: self, active: true)
        subscription.save if subscription.update_subscription({ stripe_token: stripe_token, coupon: coupon })
        #stripe_token = nil
      end
    end

  end

  def cancel_subscription
    if subscription.nil?
      raise 'User: calling cancel_subscription with no subscription'
    else
      subscription.cancel_subscription
      subscription.destroy
    end
  end

  def plan
    'Undefined' # to avoid nulls returned default to undefined.
    Plan.where(role: roles.first).first if roles.count > 0
  end

  def expire
    # mark the account as being inactive
    if subscription.nil?
      raise 'User: Calling expire with no subscription'
    else
      subscription.update_attributes(active: false)
      unless email.include? '@example.com'
        AppLog.log_with_user(self, 'Sending cancellation email')
        UserMailer.cancellation_email(self).deliver if save
      end
    end
  end

  def subscribe
    if subscription.nil?
      raise 'Calling subscribe with no subscription'
    else
      subscription.update_attributes(active: true)
      unless email.include? '@example.com'
        AppLog.log_with_user(self, 'Sending welcome email')
        send_welcome_email if save # If subscribed send a welcome email
      end
    end
  end

  def send_welcome_email
    if subscription.nil?
      raise 'calling welcome email with no subscription'
    else
      unless email.include? '@example.com'
        AppLog.log_with_user(self, 'Sending welcome email')
        UserMailer.welcome_email(self).deliver
      end
    end
  end
end
