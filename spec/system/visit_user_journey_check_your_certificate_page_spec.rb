require 'rails_helper'

RSpec.describe 'Check your certificate page', type: :system do
  include CertificateSupport

  before(:each) do
    login_certificate_manager_user
  end

  it 'shows check your certificate page for msa encryption and successfully goes to next page' do
    certificate = create(:msa_encryption_certificate)
    msa_component = certificate.component
    visit upload_certificate_path(msa_component.component_type, msa_component.id, msa_component.encryption_certificate_id)
    fill_in 'certificate_value', with: certificate.value
    click_button 'Continue'
    expect(current_path).to eql check_your_certificate_path(msa_component.component_type, msa_component.id, msa_component.encryption_certificate_id)
    expect(page).to have_content 'MSA'
    expect(page).to have_content 'Encryption'
    click_button 'Use this certificate'
    expect(current_path).to eql confirmation_path(msa_component.component_type, msa_component.id, msa_component.encryption_certificate_id)
  end

  it 'shows check your certificate page for sp encryption and successfully goes to next page' do
    certificate = create(:sp_encryption_certificate)
    sp_component = certificate.component
    visit upload_certificate_path(sp_component.component_type, sp_component.id, sp_component.encryption_certificate_id)
    fill_in 'certificate_value', with: certificate.value
    click_button 'Continue'
    expect(current_path).to eql check_your_certificate_path(sp_component.component_type, sp_component.id, sp_component.encryption_certificate_id)
    expect(page).to have_content 'VSP'
    expect(page).to have_content 'Encryption'
    click_button 'Use this certificate'
    expect(current_path).to eql confirmation_path(sp_component.component_type, sp_component.id, sp_component.encryption_certificate_id)
  end

  it 'shows check your certificate page for msa signing and successfully goes to next page' do
    certificate = create(:msa_signing_certificate)
    msa_component = certificate.component
    visit upload_certificate_path(msa_component.component_type, msa_component.id, msa_component.signing_certificates[0])
    fill_in 'certificate_value', with: certificate.value
    click_button 'Continue'
    expect(current_path).to eql check_your_certificate_path(msa_component.component_type, msa_component.id, msa_component.signing_certificates[0])
    expect(page).to have_content 'MSA'
    expect(page).to have_content 'Signing'
    click_button 'Use this certificate'
    expect(current_path).to eql confirmation_path(msa_component.component_type, msa_component.id, msa_component.signing_certificates[0])
  end

  it 'shows check your certificate page for sp signing and successfully goes to next page' do
    certificate = create(:sp_signing_certificate)
    sp_component = certificate.component
    visit upload_certificate_path(sp_component.component_type, sp_component.id, sp_component.signing_certificates[0])
    fill_in 'certificate_value', with: certificate.value
    click_button 'Continue'
    expect(current_path).to eql check_your_certificate_path(sp_component.component_type, sp_component.id, sp_component.signing_certificates[0])
    expect(page).to have_content 'VSP'
    expect(page).to have_content 'Signing'
    click_button 'Use this certificate'
    expect(current_path).to eql confirmation_path(sp_component.component_type, sp_component.id, sp_component.signing_certificates[0])
  end

end
