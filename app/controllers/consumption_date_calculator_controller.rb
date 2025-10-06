class ConsumptionDateCalculatorController < ApplicationController
  def show
    @form = default_form_params
    @result = nil
  end

  def create
    @form = calculator_params.to_h
    @result = rand(2000)

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
      quantity: nil,
      units: "",
      rate_amount: nil,
      rate_period: "per_day",
      start_date: Date.current,
      inclusive: "1"
    }
  end

  def calculator_params
    params.require(:consumption_date_calculator)
    .permit(:quantity, :consumption_rate)
  end
end
