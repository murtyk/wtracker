# we might not be using this now but the intent is do imports in background
class ImporterJob
  attr_reader :params, :user_id
  def initialize(params, current_user)
    @params = params
    @user_id = current_user.id
  end

  def perform
    current_user = User.unscoped.find(user_id)
    importer = Importer.new_importer(params, current_user)
    importer.import
  end
end
