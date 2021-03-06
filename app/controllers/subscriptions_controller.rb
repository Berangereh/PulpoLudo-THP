class SubscriptionsController < ApplicationController
  
  before_action :authenticate_user!
  before_action :good_user?
  
  #ecrire un before action update uniquement accessible a l'admin(probablement plutot metre update dans un namespace admin)
  
  def index
    @user = current_user
    @subscriptions = @user.subscriptions
    @invoice = Stripe::Invoice.list(limit: 3, customer: @user.stripe_id).first.invoice_pdf
  end

  private

  def good_user?
    user_id = params[:user_id]
    check_user(user_id)
  end

end
