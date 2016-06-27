class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  attr_accessor :yahoo_client

  def yahoo_client
    @yahoo_client ||= YahooFinance::Client.new
  end

end
