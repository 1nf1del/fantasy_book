# == Schema Information
#
# Table name: mass_emails
#
#  id             :integer          not null, primary key
#  message        :text(65535)
#  subject        :string(255)
#  group          :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  send_at        :datetime
#  delayed_job_id :integer
#

class MassEmail < ActiveRecord::Base

  validates :message, presence: true
  validates :subject, presence: true
  validates :group, presence: true

  just_define_datetime_picker :send_at

  enum group: [ :Players_And_VIP, :Players, :VIP, :AllAdmins]

  after_initialize :set_time
  after_save :notify, if: Proc.new {|a| a.send_at_changed?}
  after_save :get_dj_id, if: Proc.new {|a| a.send_at_changed?}
  before_destroy :delete_dj

  def set_time
    self.send_at ||= Time.now + 10.minutes
  end

  def delete_dj
    return if self.delayed_job_id.blank?
    if Delayed::Job.where(id: self.delayed_job_id).exists?
      Delayed::Job.find(self.delayed_job_id).destroy
    end
  end

  def get_dj_id
    Delayed::Job.find(self.delayed_job_id).destroy if self.delayed_job_id
    self.delayed_job_id = Delayed::Job.where(queue: "Notify").last.id
    self.save
  end

  handle_asynchronously :get_dj_id, queue: "Get_DJ_ID", :run_at => Proc.new { 5.seconds.from_now }

  def notify
    if self.group == "Players_And_VIP"
      recipients = User.where("role = ? or role = ?", 1, 3)
    elsif self.group == "Players"
      recipients = User.where(role: 1)
    elsif self.group == "VIP"
      recipients = User.where(role: 3)
    elsif self.group == "AllAdmins"
      recipients = User.where("role = ? or role = ?", 0, 2)
    end
    recipients.each do |recipient|
      if recipient.email_notif?
        MailgunMailer.mass_email(self, recipient).deliver_later
      end
      #if recipient.sms_notif?
       # Text.mass_sms(self, recipient)
      #end
    end
    self.delayed_job_id = nil
    self.save
  end

  handle_asynchronously :notify, queue: "Notify", :run_at => Proc.new { |i| i.send_at }

end
