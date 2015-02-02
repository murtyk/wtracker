class CreateTraineeEmails < ActiveRecord::Migration
  def change
    create_table :trainee_emails do |t|
      t.references :account, index: true
      t.references :user, index: true
      t.references :klass, index: true
      t.text :trainee_names
      t.text :trainee_ids
      t.string :subject
      t.text :content

      t.timestamps
    end
  end
end
