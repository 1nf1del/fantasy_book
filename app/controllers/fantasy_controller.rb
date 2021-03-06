class FantasyController < ApplicationController
  layout "fantasy"
  before_action :user_required

  def my_action
    @wagers = Wager.where(user_id: current_user.id, state: 0)
    @risk_counter = 0
    @win_counter = 0
  end

  def my_history
    unless params[:beg_date].present?
      params[:beg_date] = (DateTime.now - 7.days).strftime("%m/%d/%Y")
      params[:end_date] = DateTime.now.strftime("%m/%d/%Y")
    end
    start_params = params[:beg_date]
    ending_params = params[:end_date]
    start_date = start_params[6..9] + start_params[5] + start_params[0..2] + start_params[3..4] + " 00:00:00"
    ending_date = ending_params[6..9] + ending_params[5] + ending_params[0..2] + ending_params[3..4] + " 23:59:59"
    @wagers = Wager.joins(:prop).where('props.time' => start_date..ending_date,
      'state' => 1..3, 'user_id' => current_user.id)
    @result_counter = 0
  end

  def my_stats
    render
  end

  def leaderboard
    render
  end

end
