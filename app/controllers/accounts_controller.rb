class AccountsController < ApplicationController
  before_action :signed_in?, only: %i[show]

  # newかeditか分からない
  def new
    @account = current_user.account
  end

  def deposit
    amount = params[:account][:amount].to_i
    account = current_user.account
    account.update!(balance: account.balance + amount)

    redirect_to user_path, notice: "Deposit successful."
  end
end
