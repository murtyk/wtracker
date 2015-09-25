# mainly used in search action
class ApplicantDecorator < ApplicationDecorator
  delegate_all

  def unemployment_proof_supplied
    return unless trainee
    tf = trainee.unemployment_proof_file
    return h.link_to(tf.name, h.trainee_file_url(tf)) if tf

    self_certified = unemployment_proof_initial && unemployment_proof_date
    return 'Self Certified' if self_certified
  end

  def trainee_tapo_id
    return unless trainee
    h.link_to(trainee.id, h.trainee_path(trainee))
  end

  def source_name
    object.source
  end
end
