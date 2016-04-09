# for klasses index action
class KlassesService
  def metrics(user)
    programs_data = []

    Program.all.decorate.each do |program|
      init_counts(program, user)
      data = []

      @klasses.each do |klass|
        data << [klass,
                 enrolled(klass.id),
                 placed(klass.id),
                 dropped(klass.id),
                 klass_fs_counts(klass.id)]
      end

      programs_data << [program.name, program.id, data]
    end

    programs_data
  end

  def funding_sources_names
    funding_sources.pluck(:name)
  end

  def funding_sources
    @funding_sources ||= FundingSource.order(:name)
  end

  private

  def klass_link(name, id)
    "<a href='/klasses/#{id}'>#{name}</a>"
  end

  def init_counts(program, user)
    @klasses = program.user_klasses(user)
    k_ids = @klasses.map(&:id)
    klass_trainees = KlassTrainee.where(klass_id: k_ids)

    @enrolled_counts = klass_trainees.group(:klass_id).count
    @placed_counts = klass_trainees.where(status: 4).group(:klass_id).count
    @dropped_counts = klass_trainees.where(status: 3).group(:klass_id).count
  end

  def enrolled(klass_id)
    @enrolled_counts[klass_id]
  end

  def placed(klass_id)
    @placed_counts[klass_id]
  end

  def dropped(klass_id)
    @dropped_counts[klass_id]
  end

  def klass_fs_counts(klass_id)
    funding_sources.map{ |fs| fs_trainees_count(klass_id, fs.id) }
  end

  def fs_trainees_count(klass_id, fs_id)
    @fs_counts ||= KlassTrainee.joins(:trainee, :klass).group(:klass_id, :funding_source_id).count

    @fs_counts[[klass_id, fs_id]]
  end
end
