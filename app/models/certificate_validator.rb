class CertificateValidator < ActiveModel::EachValidator
  def validate_each(record, _attribute, value)
    x509 = x509_certificate(record, value)
    return false if x509.nil?

    certificate_has_appropriate_not_after(record, x509)
    certificate_key_is_supported(record, x509)
  end

  def load_value_as_x509_cert(value)
    OpenSSL::X509::Certificate.new(value)
  rescue OpenSSL::X509::CertificateError, TypeError
    nil
  end

  def load_decoded_value_as_x509_cert(value)
    load_value_as_x509_cert(Base64.decode64(value)) unless value.nil?
  end

  def load_as_x509_certificate(value)
    load_value_as_x509_cert(value) || load_decoded_value_as_x509_cert(value)
  end

  def x509_certificate(record, value)
    load_as_x509_certificate(value).tap do |x509|
      record.errors.add(:certificate, 'is not a valid x509 certificate') if x509.nil?
    end
  end

  def certificate_has_appropriate_not_after(record, x509)
    if x509.not_after < Time.now
      record.errors.add(:certificate, 'has expired')
    elsif x509.not_after < Time.now + 30.days
      record.errors.add(:certificate, 'expires too soon')
    elsif x509.not_after > Time.now + 1.year
      record.errors.add(:certificate, 'valid for too long')
    end
  end

  def certificate_key_is_supported(record, x509)
    if x509.public_key.is_a?(OpenSSL::PKey::RSA)
      certificate_is_strong(record, x509)
    else
      record.errors.add(:certificate, 'in not RSA')
    end
  end

  def certificate_is_strong(record, x509)
    return if x509.public_key.params['n'].num_bits >= 2048

    record.errors.add(:certificate, 'key size is less than 2048')
  end
end