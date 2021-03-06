class PropsController < ApplicationController
  layout "prop"

  def index
    if params[:q].present?
      @props = Prop.search(params[:q]).order('time')
    elsif params[:sport_id].present?
      @props = Prop.where(sport_id: params[:sport_id], state: 1).order('time')
    else
      @props = Prop.where(state: 1).order('time')
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    @prop = Prop.find(params[:id])
    respond_to do |format|
      if @prop.update_attributes(prop_params)
        format.js { render nothing: true }
      end
    end
  end

  def pc
    respond_to do |format|
      format.json do
        prop_choice_id = params[:prop_choice_id]
        @prop_choice = PropChoice.find_by id: prop_choice_id
        render json: @prop_choice.to_json(:include => [:prop], :methods => [:display_line, :display_spread, :name, :available_dollars, :display_proposition])
      end
    end
  end

  def prop
    respond_to do |format|
      format.json do
        prop_id = params[:prop_id]
        @prop = Prop.find_by id: prop_id
        render json: @prop.to_json(:include => [:prop_choices])
      end
    end
  end

  private

  def prop_params
    params.require(:prop).permit(:winner, :state)
  end

end

