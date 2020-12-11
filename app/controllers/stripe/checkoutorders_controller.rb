class Stripe::CheckoutordersController < ApplicationController

  def new
    @total = params[:total].to_d
    @session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [
        {
          name: "Frais d'envoi des 5 jeux de société",
          amount: (@total*100).to_i,
          currency: 'eur',
          quantity: 1
        },
      ],
      success_url: stripe_checkoutorders_success_url + '?session_id={CHECKOUT_SESSION_ID}',
      cancel_url: stripe_checkoutorders_cancel_url
    )
    respond_to do |format|
      format.js # renders new.js.erb
    end
  end

  def success
    @user = current_user
    @session = Stripe::Checkout::Session.retrieve(params[:session_id])
    @payment_intent = Stripe::PaymentIntent.retrieve(@session.payment_intent)

    @order = Order.create(user: @user, status: "bien arrivé")
    @order.games = current_cart.games
    
    if @order.save
      @shipping_send = Shipping.new(price: 0, provider: "Mondial Relay", send_at: Time.new, status: "livraison aller", order: @order, trakcing_number: "????")

      @shipping_back = Shipping.new(price: 0, provider: "Mondial Relay", send_at: Time.new, status: "livraison retour", order: @order, trakcing_number: "????")

      if @shipping_send.save && @shipping_back.save
        current_cart.games.each do |game|
          game.leased!
        end
        current_cart.send_cart!
        flash[:notice] = "Vos jeux vous ont bien été envoyés."
        redirect_to(user_path(@user))
      else
        failure_new_shipping_email(@order, @shipping_send, @shipping_back)
      end
    else
      failure_new_order_email(@order)
    end
  end

  def cancel
  end

  private

  def failure_new_order_email(order)
    UserMailer.issue_order_email(order).deliver_now
    AdminMailer.issue_order_email_admin(order).deliver_now
  end

  def failure_new_shipping_email(order, shipping_send, shipping_back)
    user = order.user

    UserMailer.issue_order_email(order).deliver_now
    AdminMailer.issue_shipping_email_admin(shipping_send, shipping_back, user).deliver_now
  end

  def finish_order_email(order)
    UserMailer.finish_order_email(order).deliver_now
  end

  def good_user?
    user_id = params[:user_id]
    check_user(user_id)
  end

  def remove_all_game(cart)
    cart.games.each do |game|
      game.in_stock!
    end
    cart.games.delete_all
  end

end
