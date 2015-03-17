# a Grant or College account can have multiple programs
# and many classes in a program
class Program < ActiveRecord::Base
  INTEREST_TYPES = { 1 => 'Interested', 2 => 'Not Interested', 3 => 'No Response' }

  default_scope { where(account_id: Account.current_id) }
  default_scope { where(grant_id: Grant.current_id) }
  attr_accessible :description, :name, :hours,
                  :sector_id, :grant_id

  validates :name, presence: true, length: { minimum: 3, maximum: 80 }

  belongs_to :grant
  belongs_to :account
  belongs_to :sector

  has_many :klasses, dependent: :destroy
  has_many :klass_interactions, through: :klasses

  has_many :klass_trainees, through: :klasses
  has_many :trainees, -> { order(:first, :last).uniq }, through: :klass_trainees

  delegate :name, to: :grant, prefix: true

  def scheduled_classes
    klasses.where('DATE(start_date) > ?', Time.now.to_date).order('start_date')
  end

  def ongoing_classes
    klasses.joins(:college)
      .where('DATE(start_date) <= ? and DATE(end_date) >= ?',
             Time.now.to_date, Time.now.to_date)
      .order('colleges.name')
      .order('start_date desc')
  end

  def completed_classes
    klasses.where('DATE(end_date) < ?', Time.now.to_date)
      .order('start_date desc')
  end

  def classes_by_status
    %w(scheduled_classes ongoing_classes completed_classes).map do |s|
      s_klasses = send(s)
      [s, s_klasses] if s_klasses.any?
    end.compact
  end

  def klass_count
    klasses.count
  end

  def enrolled_count(klass_status)
    classes = send(klass_status)  # don't use klasses since it is a member
    classes.map { |klass| klass.enrolled_count.to_i }.inject(:+)
  end

  def dropped_count(klass_status)
    classes = send(klass_status)  # don't use klasses since it is a member
    classes.map { |klass| klass.dropped_count.to_i }.inject(:+)
  end

  def completed_count(klass_status)
    classes = send(klass_status)  # don't use klasses since it is a member
    classes.map { |klass| klass.completed_count.to_i }.inject(:+)
  end

  def continuing_education_count(klass_status)
    classes = send(klass_status)  # don't use klasses since it is a member
    classes.map { |klass| klass.continuing_education_count.to_i }.inject(:+)
  end

  def placed_count(klass_status)
    classes = send(klass_status)  # don't use klasses since it is a member
    classes.map { |klass| klass.placed_count.to_i }.inject(:+)
  end

  def not_placed_count(klass_status)
    classes = send(klass_status)  # don't use klasses since it is a member
    classes.map { |klass| klass.not_placed_count.to_i }.inject(:+)
  end

  def placement_rate(klass_status)
    # completed is our target for placement, exclude continuing education

    dividend = placed_count(klass_status) + continuing_education_count(klass_status)
    divider  = divisor(klass_status)
    divider > 0 ? (dividend.to_f * 100 / divider).round(0).to_s + '%' : ''
  end

  def divisor(klass_status)
    not_placed_count(klass_status) +
      placed_count(klass_status) +
      continuing_education_count(klass_status)
  end

  def self.selection_list
    pluck(:name, :id)
  end

  # need this for grants list
  def program_klasses
    Klass.unscoped.where(program_id: id)
  end
  # need this for grants list
  def trainees_count
    KlassTrainee.unscoped.where(klass_id: program_klasses.pluck(:id)).count
  end

  def trainee_ids
    return @trainee_ids if @trainee_ids
    klass_ids = klasses.pluck(:id)
    @trainee_ids = KlassTrainee.unscoped.select(:trainee_id)
                   .where(klass_id: klass_ids).pluck(:trainee_id).uniq
    @trainee_ids
  end
end
