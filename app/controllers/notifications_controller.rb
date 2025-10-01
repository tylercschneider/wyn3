class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: [:show]
  after_action :mark_as_seen, only: [:index]

  def index
    @pagy, @notifications = pagy current_user.notifications.where(account: current_account).newest_first, limit: 25
  end

  def nav
    @pagy, @notifications = pagy current_user.notifications.where(account: current_account).newest_first, limit: 10
  end

  def show
    @notification.mark_as_read
    redirect_to @notification.event.url
  end

  def mark_as_read
    current_user.notifications.where(account: current_account).mark_as_read_and_seen
    redirect_to notifications_path
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to notifications_path
  end

  def mark_as_seen
    @notifications.mark_as_seen
  end
end
