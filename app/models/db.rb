# frozen_string_literal: true

# Might not be using now. Keep it anyway.
class DB
  def self.query(sql)
    pg_results = ActiveRecord::Base.connection.execute(sql)
    pg_results.map { |result| OpenStruct.new(result) }
  end
end
