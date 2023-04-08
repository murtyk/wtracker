# frozen_string_literal: true

# mainly used in search action
class ApplicantDecorator < ApplicationDecorator
  delegate_all

  def unemployment_proof_supplied
    return unemp_proof_link if unemp_proof_file
    return 'Self Certified' if self_certified?
  end

  def self_certified?
    unemployment_proof_initial && unemployment_proof_date
  end

  def trainee_tapo_id
    return unless trainee

    h.link_to(trainee.id, h.trainee_path(trainee))
  end

  def source_name
    object.source
  end

  def unemp_proof_file
    return unless trainee

    trainee.unemployment_proof_file
  end

  def unemp_proof_link
    h.link_to(unemp_proof_file_name, unemp_proof_url)
  end

  def unemp_proof_url
    web_address + "/trainee_files/#{unemp_proof_file.id}"
  end

  def unemp_proof_file_name
    unemp_proof_file.name
  end

  def web_address
    return @web_address if @web_address

    account = Account.find Account.current_id
    @web_address = Host.web_address(account.subdomain)
  end
end
