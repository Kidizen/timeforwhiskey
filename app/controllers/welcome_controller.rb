class WelcomeController < ApplicationController
  http_basic_authenticate_with name: "kidizen", password: "itzn1212"
  def index
  end
end
