ActiveAdmin.register Bonus do
  filter :state, label: "Status", as: :select, collection: Bonus.states
  filter :user, as: :select, collection: User.where("role = ? or role = ?", 1, 3).order("username").collect {|u| ["#{u.username}", u.id]}
  filter :bonus_code
  menu label: "Bonuses"
  menu priority: 10

  index do
    column "User" do |wager|
      link_to(wager.user.username, admin_user_path(wager.user.id))
    end
    column "Amount" do |bonus|
      number_to_currency bonus.amount_dollars
    end
    column "Pending" do |bonus|
      number_to_currency bonus.pending_dollars
    end
    column "Released" do |bonus|
      number_to_currency bonus.released_dollars
    end
    column "Bonus Code" do |bonus|
      link_to(bonus.bonus_code.code, admin_bonus_code_path(bonus.bonus_code.id)) if bonus.bonus_code
    end
    column :state
    actions
  end

  show do
    attributes_table do
      row "User" do |bonus|
        link_to(bonus.user.username, admin_user_path(bonus.user.id))
      end
      row "Amount" do
        number_to_currency bonus.amount_dollars
      end
      row "Pending" do
        number_to_currency bonus.pending_dollars
      end
      row "Released" do
        number_to_currency bonus.released_dollars
      end
      row :rollover
      row "Bonus Code" do |bonus|
        link_to(bonus.bonus_code.code, admin_bonus_code_path(bonus.bonus_code.id)) if bonus.bonus_code
      end
      row :state
      row :exp_date
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Bonus" do
      f.input :user, required: true, as: :select, collection: User.where("role = ? or role = ?", 1, 3).order("username").collect {|u| ["#{u.username}", u.id]}
      f.input :amount_dollars, label: "Amount", required: true
      if f.object.new_record?
        f.input :bonus_code, label: "Bonus Code", as: :select, collection: BonusCode.all.collect {|bc| ["#{bc.code} - #{bc.rollover}x rollover", bc.id]}
        f.input :rollover, hint: "Leave blank if using Bonus Code"
        f.input :exp_date, label: "Exp Date", as: :datepicker, hint: "Leave blank if using Bonus Code"
      else
        f.input :pending_dollars, label: "Pending"
        f.input :rollover
        f.input :bonus_code_id, label: "Bonus Code", as: :select, collection: BonusCode.all.collect {|bc| ["#{bc.code} - #{bc.percentage}% with #{bc.rollover}x rollover", bc.id]}
        f.input :state, label: "Status", as: :select, collection: ["Pending", "Complete", "Expired"]
        f.input :exp_date, label: "Exp Date"
      end
    end
    f.actions
  end

  permit_params :user_id, :amount_dollars, :bonus_code_id, :pending_dollars,
  :rollover, :state, :exp_date

  controller do
    before_filter state: :index do
        params[:q] = {state_eq: "Pending"} if params[:commit].blank?
    end
  end

end
