class Billing::Subscriptions::PausesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_account_admin
  before_action :set_subscription

  def show
  end

  def update
    @subscription.pause
    redirect_to billing_path
  rescue Pay::Error => e
    flash[:alert] = e.message
    render :show, status: :unprocessable_entity
  end

  private

  def set_subscription
    @subscription = current_account.pay_subscriptions.find_by_prefix_id!(params[:subscription_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to billing_path
  end
end
