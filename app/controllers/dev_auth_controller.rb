class DevAuthController < ApplicationController
  skip_before_action :authenticate_user!

  def show
  end
end
