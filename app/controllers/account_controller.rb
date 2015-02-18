class AccountController < ApplicationController
  layout "account"

  def deposit
    render
  end

  def withdraw
    render
  end

  def transfer
    @transfers = Transfer.where("receiver_id = ? OR sender_id = ?", current_user.id, current_user.id)
  end

  def create_transfer
    receiver = User.find_by username: params[:receiver]
    binding.pry
    transfer = Transfer.new transfer_params
    transfer.receiver_id = receiver.id
    transfer.sender_id = current_user.id
    if transfer.save
      redirect_to my_account_transfer_path
    else
      render action: :transfer
    end
  end

  def balance
    render
  end

  def challenge
    render
  end

  def social
    render
  end

  private

  def transfer_params
    params.permit(:amount_dollars)
  end

end
