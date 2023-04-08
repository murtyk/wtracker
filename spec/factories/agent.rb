FactoryBot.define do
  factory :agent do
    info do
      {
        'ip' => '173.54.255.201',
        'asn' => 'AS701',
        'isp' => 'MCI Communications Services, Inc. d/b/a Verizon Business',
        'city' => 'Westwood', 'offset' => '-4', 'region' => 'New Jersey',
        'country' => 'United States', 'dma_code' => '0', 'latitude' => '41.0099',
        'timezone' => 'America/New_York', 'area_code' => '0',
        'longitude' => '-74.0073', 'postal_code' => '07675',
        'region_code' => 'NJ', 'country_code' => 'US', 'country_code3' => 'USA',
        'continent_code' => 'NA'
      }
    end
  end
end
