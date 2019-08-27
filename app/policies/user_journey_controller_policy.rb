class UserJourneyControllerPolicy < ApplicationPolicy
  attr_reader :user, :certificate

  def initialize(user, certificate)
    @user = user
    @certificate = certificate
  end

  def index?
    user.permissions.certificate_management
  end

  def before_you_start?
    user.permissions.certificate_management
  end

  def view_certificate?
    user.permissions.certificate_management
  end

  def upload_certificate?
    user.permissions.certificate_management
  end

  def upload?
    user.permissions.certificate_management
  end

  def check_your_certificate?
    user.permissions.certificate_management
  end

  def submit?
    user.permissions.certificate_management
  end

  def confirmation?
    user.permissions.certificate_management
  end

  def confirm?
    user.permissions.certificate_management
  end
end