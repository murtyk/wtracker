# factory for sending bulk emails to trainees and employers
class EmailFactory
  def self.create_trainee_email(all_params, current_user)
    params      = all_params[:trainee_email]
    trainee_ids = params[:trainee_ids]
    klass_id    = params[:klass_id]

    trainee_ids = JSON.parse trainee_ids if trainee_ids.is_a? String
    if trainee_ids.include?('0')
      klass = Klass.find(klass_id)
      trainee_ids = klass.trainees_with_email.pluck(:id)
    end

    if trainee_ids.size > 0
      trainees        = Trainee.where(id: trainee_ids)
      trainee_names   = trainees.map { |t| t.name }
      email_addresses = trainees.pluck(:email)

      e_params      = params.merge(trainee_ids: trainee_ids, trainee_names: trainee_names)
      trainee_email = current_user.trainee_emails.new(e_params)
    end

    if trainee_email.save
      UserMailer.send_trainee_email(trainee_email, email_addresses,
                                    params[:use_job_leads_email]).deliver
    end
    trainee_email
  end

  def self.create_email(all_params, current_user)
    params = all_params[:email]

    # debugger
    file_ids = params[:trainee_file_ids]
    trainee_file_ids = file_ids.blank? ? nil : file_ids.split(':')

    email = current_user.emails.new(subject: params[:subject],
                                    content: params[:content],
                                    trainee_file_ids: trainee_file_ids)

    contact_ids = params[:contact_ids]
    contact_ids.delete('')
    email.contact_ids = contact_ids
    if contact_ids.count == 0
      email.errors.messages[:contact_ids] = ['Add at least one employer contact']
      return email
    end

    contact_ids.each { |contact_id| email.contact_emails.build(contact_id: contact_id) }

    attachments = build_attachments(email, trainee_file_ids, params[:attachments])

    email.klass_id = params[:klass_id]

    build_trainee_submits(email, contact_ids,
                          trainee_file_ids) if Account.mark_jobs_applied?

    UserMailer.send_employer_emails(email, attachments).deliver if email.save
    email
  end

  def self.build_attachments(email, trainee_file_ids, file_attachments)
    attachments = {}
    if trainee_file_ids
      trainee_files = TraineeFile.includes(:trainee).where(id: trainee_file_ids)
      trainee_files.each do |tf|
        url = Amazon.file_url(tf.file)
        name = unique_name(attachments, tf.name)
        attachments[name] = open(url).read
      end
    end

    if file_attachments
      file_attachments.each do |key, attached_file|
        name = attached_file.original_filename
        s3file = Amazon.store_file(attached_file, 'attachments')
        email.attachments.new(name: name, file: s3file)
        url = Amazon.file_url(s3file)

        attachments[unique_name(attachments, name)] = open(url).read
      end
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

  def self.build_trainee_submits(email, contact_ids, trainee_file_ids)
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
