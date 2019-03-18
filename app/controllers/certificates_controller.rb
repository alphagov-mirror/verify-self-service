class CertificatesController < ApplicationController
  
  def index
    @uploads = Certificate.all
  end

  def upload
    @upload = UploadCertificateEvent.new
  end

  def create
    @upload = UploadCertificateEvent.create(upload_params)
    if @upload.valid?
      redirect_to certificates_path
    else
      Rails.logger.info(@upload.errors.full_messages)
      render :upload
    end
  end

  private

  def upload_params
    params.require(:certificate).permit(
      :value,
      :usage
    )
  end

end
