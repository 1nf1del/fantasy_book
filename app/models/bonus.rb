# == Schema Information
#
# Table name: bonuses
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  amount     :integer
#  pending    :integer
#  kind       :string(255)
#  rollover   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  state      :integer
#  released   :integer          default("0")
#

class Bonus < ActiveRecord::Base
  include AASM, StorageConversions

  belongs_to :user
  validates :user_id, presence: true
  validates :amount, presence: true

  store_cents :amount, :pending, :released

  enum state: [ :Pending, :Complete, :Expired ]

  before_validation :set_pending, on: :create

  def set_pending
    self.pending = self.amount
  end

  def process_bonus(wager_amount)
    self.pending -= wager_amount / self.rollover
    self.save
    if self.pending <= 0
      extra = self.pending * self.rollover * -1
      self.pending = 0
      self.complete_bonus!
      nextBonus = Bonus.find_by(user_id: self.user_id, state: "Pending")
      nextBonus.pending -= extra / nextBonus.rollover
      nb_earned = nextBonus.amount_dollars - nextBonus.pending_dollars
      nb_not_released = nb_earned - nextBonus.released_dollars
      nb_not_released = nb_not_released - nb_not_released % 10
      nextBonus.user.balance += nb_not_released * 100
      nextBonus.user.save
      nextBonus.released += nb_not_released * 100
      nextBonus.save
    end
    earned = self.amount_dollars - self.pending_dollars
    not_released = earned - self.released_dollars
    not_released = not_released - not_released % 10
    self.user.balance += not_released * 100
    self.user.save
    self.released += not_released * 100
    self.save
  end

  aasm column: :state do
    state :Pending, initial: true

    event :complete_bonus do
      transitions from: :Pending, to: :Complete
    end

    state :Complete

    event :expire_bonus do
      transitions from: :Pending, to: :Expired
    end

    state :Expired

  end
end
