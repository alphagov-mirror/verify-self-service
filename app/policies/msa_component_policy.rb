class MsaComponentPolicy < ApplicationPolicy
  attr_reader :user, :post

  def initialize(user, post)
    @user = user
    @post = post
  end

  def create?
    return true if user.has_role("gds")

    return true if user.has_role("dev")

    false
  end
end
