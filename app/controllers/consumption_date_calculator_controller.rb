class ConsumptionDateCalculatorController < ApplicationController
  def show
    @form = default_form_params
    @result = nil
  end

  def create
    @form = calculator_params.to_h
    @result = Calculate::Consumption.consumed_by_date(
      start_date: @form[:start_date],
      units_of_item: @form[:units_of_item].to_i,
      quantity_consumed: @form[:quantity_consumed].to_i,
      consumption_period: @form[:consumption_period]
    )

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "calculation_result",
          partial: "consumption_date_calculator/result",
          locals: {result: @result, form: @form}
        )
      end

      # Fallbacks to keep Turbo happy:
      format.html do
        if result.success?
          redirect_to consumption_date_calculator_path(consumed_by: result.consumed_by, days_needed: result.days_needed)
        else
          @result = result
          render :show, status: :unprocessable_entity
        end
      end
    end
  end

  private

  def default_form_params
    {
      units_of_item: nil,
      quantity_consumed: nil,
      consumption_period: "per_day",
      start_date: Date.current
    }
  end

  def calculator_params
    params.require(:consumption_date_calculator)
      .permit(:start_date, :units_of_item, :quantity_consumed, :consumption_period)
  end
end
