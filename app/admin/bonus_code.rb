ActiveAdmin.register BonusCode do
  filter :percentage
  filter :rollover

  index do
    selectable_column
    column :code
    column "Percentage" do |bonus_code|
      number_to_percentage bonus_code.percentage, precision: 0
    end
    column :rollover
    column "Max Bonus" do |bonus_code|
      number_to_currency bonus_code.maximum_dollars, precision: 0
    end
    column "Enabled" do |bonus_code|
      bonus_code.enabled.to_s
    end
    column "One Time" do |bonus_code|
      bonus_code.one_time.to_s
    end
    actions
  end

  show do
    attributes_table do
      row :code
      row "Percentage" do |bonus_code|
        number_to_percentage bonus_code.percentage, precision: 0
      end
      row :rollover
      row "Max Bonus" do |bonus_code|
        number_to_currency bonus_code.maximum_dollars, precision: 0
      end
      row "Enabled" do |bonus_code|
        bonus_code.enabled.to_s
      end
      row "One Time" do |bonus_code|
        bonus_code.one_time.to_s
      end
      row :note
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Bonus Code Details" do
      f.input :code, required: true
      f.input :percentage, required: true
      f.input :rollover, required: true
      f.input :maximum_dollars, label: "Max Bonus Amount"
      f.input :enabled
      f.input :one_time
      f.input :note
    end
    f.actions
  end

  permit_params :code, :percentage, :rollover, :maximum_dollars,
  :enabled, :one_time, :note

end