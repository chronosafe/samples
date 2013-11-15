class DecoderLog < ActiveRecord::Base
  belongs_to :decode
  belongs_to :user

  # Statistics scopes
  scope :this_month, -> { where(created_at: Date.today.beginning_of_month..Date.today.end_of_month) }
  scope :this_week,  -> { where(created_at: Time.now.in_time_zone('Eastern Time (US & Canada)').beginning_of_week..Time.now.in_time_zone('Eastern Time (US & Canada)').end_of_week) }
  scope :this_year,  -> { where(created_at: Date.today.beginning_of_year..Date.today.end_of_year) }
  scope :this_day,   -> { where(created_at: Date.today.beginning_of_day..Date.today.end_of_day) }

  def tzone
    Time.now.in_time_zone('Eastern Time (US & Canada)')
  end


end
