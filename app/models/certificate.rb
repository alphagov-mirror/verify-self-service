class Certificate < Aggregate
  include CertificateConcern
  validates_inclusion_of :usage, in: [CERTIFICATE_USAGE::SIGNING, CERTIFICATE_USAGE::ENCRYPTION]
  validates_presence_of :usage, :value, :component
  belongs_to :component, polymorphic: true

  # scope :all_pollable, ->(environment) {
  #   select(:id, :value, :usage, :created_at, :updated_at, :component_id, :enabled, :component_type, :in_use_at, :notification_sent)
  #   .joins(sanitize_sql_for_assignment(['
  #     LEFT JOIN msa_components
  #      ON msa_components.id = certificates.component_id AND msa_components.environment = ?
  #     LEFT JOIN sp_components
  #      ON sp_components.id = certificates.component_id AND sp_components.environment = ?
  #     INNER JOIN services
  #      ON sp_components.id = services.sp_component_id OR msa_components.id = services.msa_component_id
  #     ', environment, environment]))
  #   .where(in_use_at: nil, enabled: true)
  # }

  def self.all_pollable
    Certificate.where(in_use_at: nil, enabled: true)
  end

  def to_metadata
    { name: x509.subject.to_s, value: self.value }
  end

  def encryption?
    usage == CERTIFICATE_USAGE::ENCRYPTION
  end

  def signing?
    usage == CERTIFICATE_USAGE::SIGNING
  end

  def x509
    to_x509(value)
  end

  def issuer_common_name
    x509.subject.to_a.find { |issuer, _, _| issuer == 'CN' }[1]
  end

  def expires_soon?
    x509.not_after - Time.now < 30.day
  end

  def days_left
    (x509.not_after.to_date - Time.now.to_date).to_i
  end

  def expired?
    x509.not_after < Time.now
  end

  def deploying?
    updated_at >= 10.minutes.ago
  end
end
