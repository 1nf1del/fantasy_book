# == Schema Information
#
# Table name: withdrawals
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  amount     :integer
#  method     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Withdrawal < ActiveRecord::Base
  include StorageConversions

  belongs_to :user
  validates :user_id, presence: true
  validates :amount, presence: true

  store_cents :amount
end