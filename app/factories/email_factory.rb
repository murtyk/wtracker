# factory for sending bulk emails to trainees and employers
class EmailFactory
  def self.create_trainee_email(params, current_user)
    trainee_ids = find_trainee_ids(params)

    e_params,
    email_addresses = build_email_params(trainee_ids, params)

    trainee_email = current_user.trainee_emails.new(e_params)
    if trainee_email.save
      UserMailer.send_trainee_email(trainee_email,
                                    email_addresses).deliver_now
    end
    trainee_email
  end

  def self.find_trainee_ids(params)
    trainee_ids = params[:trainee_ids]
    klass_id    = params[:klass_id]

    trainee_ids = trainee_ids.split if trainee_ids.is_a? String

    trainee_ids.delete('')

    if trainee_ids.include?('0')
      klass = Klass.find(klass_id)
      trainee_ids = klass.trainees_with_email.pluck(:id)
    end
    trainee_ids
  end

  def self.build_email_params(trainee_ids, params)
    trainees        = Trainee.where(id: trainee_ids)
    trainee_names   = trainees.map(&:name)
    email_addresses = trainees.pluck(:email)

    e_params = params.merge(trainee_ids: trainee_ids, trainee_names: trainee_names)
    [e_params, email_addresses]
  end

  # below methods are for building employer email
  def self.create_email(params, user)
    email = build_employer_email(params, user)

    return email if email.errors.any?

    build_contact_emails(email)

    attachments = build_attachments(email, email.trainee_file_ids, params[:attachments])

    build_trainee_submits(email) if Account.mark_jobs_applied?

    UserMailer.send_employer_emails(email, attachments).deliver_now if email.save
    email
  end

  def self.build_employer_email(params, user)
    file_ids = params[:trainee_file_ids]
    trainee_file_ids = file_ids.blank? ? nil : file_ids.split(':')

    email = user.emails.new(subject: params[:subject],
                            content: params[:content],
                            trainee_file_ids: trainee_file_ids)

    email.klass_id = params[:klass_id]
    add_contact_ids(email, params)
    email
  end

  def self.add_contact_ids(email, params)
    contact_ids = params[:contact_ids]
    contact_ids.delete('')

    email.contact_ids = contact_ids
    return if contact_ids.any?

    email.errors.messages[:contact_ids] = ['Add at least one employer contact']
  end

  def self.build_contact_emails(email)
    email.contact_ids.each { |c_id| email.contact_emails.build(contact_id: c_id) }
  end

  def self.build_attachments(email, trainee_file_ids, file_attachments)
    attachments = {}
    attachments = trainee_file_attachments(trainee_file_ids) if trainee_file_ids

    if file_attachments
      file_attachments.each do |_key, attached_file|
        name = attached_file.original_filename
        s3file = Amazon.store_file(attached_file, 'attachments')
        email.attachments.new(name: name, file: s3file)
        url = Amazon.file_url(s3file)

        attachments[unique_name(attachments, name)] = open(url).read
      end
    end
    attachments
  end

  def self.trainee_file_attachments(trainee_file_ids)
    attachments = {}
    trainee_files = TraineeFile.includes(:trainee).where(id: trainee_file_ids)
    trainee_files.each do |tf|
      url = Amazon.file_url(tf.file)
      name = unique_name(attachments, tf.name)
      attachments[name] = open(url).read
    end
    attachments
  end

  def self.unique_name(attachments, name)
    uname = name
    counter = 0
    while attachments[uname]
      counter += 1
      uname = name + '-' + counter.to_s
    end
    uname
  end

  def self.build_trainee_submits(email)
    contact_ids = email.contact_ids
    trainee_file_ids = email.trainee_file_ids
    trainee_ids = TraineeFile.where(id: trainee_file_ids).pluck(:trainee_id).uniq
    employer_ids = Contact.where(contactable_type: 'Employer',
                                 id: contact_ids).pluck(:contactable_id).uniq
    employer_ids.each do |employer_id|
      trainee_ids.each do |trainee_id|
        email.trainee_submits.new(title: email.subject,
                                  trainee_id: trainee_id,
                                  employer_id: employer_id,
                                  applied_on: Date.current)
      end
    end
  end
end
