# for klasses index action
class KlassesService
  def metrics(user)
    programs_data = []

    Program.all.decorate.each do |program|
      init_counts(program, user)
      data = []

      @klasses.each do |klass|
        data << [klass, enrolled(klass.id), placed(klass.id)]
      end

      programs_data << [program.name, program.id, data]
    end

    programs_data
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
  end

  def enrolled(klass_id)
    @enrolled_counts[klass_id]
  end

  def placed(klass_id)
    @placed_counts[klass_id]
  end
end
