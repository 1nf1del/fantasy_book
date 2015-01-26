# == Schema Information
#
# Table name: wagers
#
#  id         :integer          not null, primary key
#  prop_id    :integer
#  user_id    :integer
#  state      :integer          default("0")
#  risk       :integer
#  win        :integer
#  pick       :integer
#  vig        :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  spread     :float(24)
#
# Indexes
#
#  index_wagers_on_prop_id  (prop_id)
#  index_wagers_on_user_id  (user_id)
#

class Wager < ActiveRecord::Base
  include AASM, StorageConversions

  belongs_to :user
  belongs_to :prop

  validates :prop_id, presence: true
  validates :user_id, presence: true
  validates :risk, presence: true
  validates :vig, presence: true
  validates :pick, presence: true
  validate :within_maximum

  display_line :spread
  display_juice :vig
  store_cents :risk, :win

  before_validation :get_win, on: [:create, :update]

  enum state: [ :Pending, :Won, :Lost, :No_Action ]
  enum pick: [ :away, :home ]

  aasm column: :state do
    state :Pending, initial: true, after_commit: :deduct_risk

    event :win_wager do
      transitions from: :Pending, to: :Won
    end

    state :Won, after_commit: :pay_win

    event :lose_wager do
      transitions from: :Pending, to: :Lost
    end

    state :Lost

    event :void_wager do
      transitions to: :No_Action
    end

    state :No_Action, after_commit: :return_risk
  end

  def get_win
    if vig > 0
      self.win = (risk * vig / 100.0).round
    else
      self.win = (risk * -100.0 / vig).round
    end
  end

  def deduct_risk
    self.user.balance -= self.risk
    self.user.save
  end

  def pay_win
    self.user.balance += (self.risk + self.win)
    self.user.save
  end

  def return_risk
    self.user.balance += self.risk
    self.user.save
  end

  def within_maximum
    existing_wagers = Wager.where(user_id: self.user_id, prop_id: self.prop_id)
    counter = 0
    existing_wagers.map do |wager|
      unless wager.id == self.id
        counter += wager.win_dollars
      end
    end
    if counter + self.win_dollars > self.prop.maximum_dollars
      errors.add(:risk, "exceeds limit")
    end
  end
end
