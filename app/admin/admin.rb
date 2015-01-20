ActiveAdmin.register User, :as => "Admin" do
  menu :label => "Admins"

  filter :name

  index do
    selectable_column
    column :email
    column :name
    actions
  end

  show do
    attributes_table do
      row :email
      row :name
      row :current_sign_in_at
      row :last_sign_in_at
      row :current_sign_in_ip
      row :last_sign_in_ip
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :name
      f.input :role, as: :hidden, value: "0"
      if f.object.new_record?
        f.input :password, required: true
      else
        f.input :password, required: false, hint: "Leave blank to not change"
      end
    end
    f.actions
  end

  controller do
    def scoped_collection
      User.where(role: 0)
    end

    def update
      if params[:user][:password].blank?
        params[:user].delete :password
      end
      super
    end
  end

  permit_params :email, :name, :role, :password
end