class ProfileController < ApplicationController
  include AuthenticationBackend
  include MfaQrHelper

  def show
    if Rails.env.development?
      @using_stub = SelfService.service(:cognito_stub)
      @cognito_available = SelfService.service_present?(:real_client)
    end
    @user = current_user
    @mfa_status = get_user_info(access_token: current_user.access_token).preferred_mfa_setting
  end

  def switch_client
    if params[:client] == 'cognito'
      CognitoStubClient.switch_to_cognito
      flash[:notice] = 'Switched to Cognito Auth Client'
    elsif params[:client] == 'stub'
      CognitoStubClient.switch_to_stub
      flash[:notice] = 'Switched to Stub Auth Client'
    end
    redirect_to profile_path
  end

  def update_role
    if params[:assume_roles].nil?
      CognitoStubClient.update_user(role: '')
    else
      role_str = params[:assume_roles][:role_selection].join(',')
      if params[:assume_roles][:role_selection].include?(ROLE::GDS)
        CognitoStubClient.update_user(
          role: role_str, email_domain: TEAMS::GDS_EMAIL_DOMAIN,
        )
      else
        CognitoStubClient.update_user(role: role_str)
      end
    end
    UserSignOutEvent.create(user_id: warden.user.user_id)
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    flash[:notice] = 'You need to sign in again for role changes to take effect' if signed_out
    redirect_to root_path
  end

  def setup_mfa
    if mfa_setup?(access_token: current_user.access_token)
      flash[:notice] = t('profile.mfa_setup_correctly')
      redirect_to profile_path
    else
      redirect_to profile_update_mfa_path
    end
  end

  def show_change_mfa
    @form = MfaEnrolmentForm.new({})
    @secret_code = session[:secret_code] || associate_device(access_token: current_user.access_token)
    @secret_code_svg = generate_new_qr(secret_code: @secret_code, email: current_user.email)
    flash[:secret_code] = @secret_code
  end

  def warn_mfa; end

  def request_new_code
    @form = MfaEnrolmentForm.new({})
    @secret_code = associate_device(access_token: current_user.access_token)
    @secret_code_svg = generate_new_qr(secret_code: @secret_code, email: current_user.email)
    flash[:secret_code] = @secret_code
    render :show_change_mfa
  end

  def change_mfa
    @form = MfaEnrolmentForm.new(params[:mfa_enrolment_form] || {})
    if @form.valid?
      verify_code_for_mfa(access_token: current_user.access_token, code: @form.totp_code)
      flash[:sucess] = t('profile.mfa_success')
      redirect_to profile_path
    else
      mfa_page_erros
    end
  rescue InvalidConfirmationCodeException
    mfa_page_erros
  end

private

  def mfa_page_erros
    flash[:retry] = true
    @secret_code = flash.discard[:secret_code]
    @secret_code_svg = generate_new_qr(secret_code: @secret_code, email: current_user.email)
    render :show_change_mfa, status: :bad_request
  end
end
