FactoryBot.define do
  factory :job_search_profile do |f|
    f.skills { 'java,ruby,ajax' }
    f.distance { 20 }
    f.location { 'Edison,NJ' }
    f.zip { '08817' }
  end
end
