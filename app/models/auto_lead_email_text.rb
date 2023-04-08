# base class for various email texts in case of auto job leads
# grant specific
class AutoLeadEmailText < ApplicationRecord
  belongs_to :grant
end
