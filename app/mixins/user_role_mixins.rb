# role related methods for user model
module UserRoleMixins
  ROLES = { 1 => 'Director', 2 => 'Admin', 3 => 'Navigator', 4 => 'Instructor' }

  def admin_or_director?
    admin? || director?
  end

  def admin_access?
    admin_or_director? || (navigator? && acts_as_admin?)
  end

  def director?
    role == 1
  end

  def admin?
    role == 2
  end

  def navigator?
    role == 3
  end

  def instructor?
    role == 4
  end

  def grant_admin?
    grant_admins.where(grant_id: Grant.current_id).any?
  end

  def grant_names
    return nil unless navigator?
    grants.pluck(:name).join('<br>').html_safe
  end

  def update_and_assign_role(params)
    prev_role = role
    new_role = params[:role].to_i

    begin
      ActiveRecord::Base.transaction do
        update_without_password params
        change_klass_roles(prev_role, new_role)
      end
      return true
    rescue # StandardError => e
      return false
    end
  end

  def change_klass_roles(prev_role, new_role)
    # find classes accross the grants
    return unless prev_role != new_role && [3, 4].include?(prev_role)
    klass_ids = klasses.map(&:id)
    klass_instructors.destroy_all
    klass_navigators.destroy_all
    if new_role == 3
      klass_ids.each { |kid| klass_navigators.create!(klass_id: kid) }
    elsif new_role == 4
      klass_ids.each { |kid| klass_instructors.create!(klass_id: kid) }
    end
  end
end
