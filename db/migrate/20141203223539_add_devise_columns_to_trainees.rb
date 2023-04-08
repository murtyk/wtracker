# frozen_string_literal: true

class AddDeviseColumnsToTrainees < ActiveRecord::Migration
  def change
    add_column :trainees, :encrypted_password, :string, null: false, default: ''

    ## Recoverable
    add_column :trainees, :reset_password_token,   :string
    add_column :trainees, :reset_password_sent_at, :datetime

    ## Rememberable
    add_column :trainees, :remember_created_at, :datetime

    ## Trackable
    add_column :trainees, :sign_in_count,      :integer, default: 0
    add_column :trainees, :current_sign_in_at, :datetime
    add_column :trainees, :last_sign_in_at,    :datetime
    add_column :trainees, :current_sign_in_ip, :string
    add_column :trainees, :last_sign_in_ip,    :string

    ## Confirmable
    # add_column :trainees, :confirmation_token,   :string
    # add_column :trainees, :confirmed_at,         :datetime
    # add_column :trainees, :confirmation_sent_at, :datetime
    # add_column :trainees, :unconfirmed_email,    :string # Only if using reconfirmable

    ## Lockable
    # t.integer  :failed_attempts, :default => 0 # Only if lock strategy is :failed_attempts
    # add_column :trainees,   :unlock_token # Only if unlock strategy is :email or :both
    # add_column :trainees, :locked_at

    ## Token authenticatable
    # add_column :trainees, :authentication_token
  end
end
