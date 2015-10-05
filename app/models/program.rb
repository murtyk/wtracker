# a Grant or College account can have multiple programs
# and many classes in a program
class Program < ActiveRecord::Base
  KLASSES_ORDER = 'colleges.name, start_date desc, end_date desc'

  default_scope { where(account_id: Account.current_id) }
  default_scope { where(grant_id: Grant.current_id) }

  validates :name, presence: true, length: { minimum: 3, maximum: 80 }

  belongs_to :grant
  belongs_to :account
  belongs_to :sector

  has_many :klasses, dependent: :destroy
  has_many :klass_interactions, through: :klasses

  has_many :scheduled_classes,
           -> { includes(:college).where('start_date > ?', Date.today).order(KLASSES_ORDER) },
           class_name: 'Klass'

  has_many :ongoing_classes,
           -> { includes(:college).where(pred_ongoing_klasses).order(KLASSES_ORDER) },
           class_name: 'Klass'

  has_many :completed_classes,
           -> { includes(:college).where(pred_completed_klasses).order(KLASSES_ORDER) },
           class_name: 'Klass'

  has_many :klass_trainees, through: :klasses
  has_many :trainees, -> { order(:first, :last).uniq }, through: :klass_trainees

  delegate :name, to: :grant, prefix: true

  def klass_count
    klasses.count
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
