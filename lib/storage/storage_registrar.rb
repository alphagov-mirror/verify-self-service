class StorageRegistrar
  def initialize
    Rails.logger.info 'Loading storage client...'
    if Rails.env.production?
      Rails.logger.info 'registering production storage client'
      register_production_client
    elsif Rails.env.development?
      Rails.logger.info 'registering development storage client'
      register_dev_client
    else
      Rails.logger.info 'registering stub storage client'
      register_stub_client
    end
  end

  def register_production_client
    SelfService.register_service(
      name: :storage_client,
      client: Aws::S3::Client.new
    )
  end

  def register_dev_client
    s3_client = Aws::S3::Client.new(stub_responses: true)
    s3_client.stub_responses(:put_object, ->(context) {
      Rails.logger.info(JSON.parse(context.params[:body].string))
    })

    SelfService.register_service(
      name: :storage_client,
      client: s3_client
    )
  end

  def register_stub_client
    s3_client = Aws::S3::Client.new(stub_responses: true)
    s3_client.stub_responses(:put_object, {})
    s3_client.stub_responses(:get_object, {})

    SelfService.register_service(
      name: :storage_client,
      client: s3_client
    )
  end
end
