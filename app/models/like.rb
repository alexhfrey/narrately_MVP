class Like < ActiveRecord::Base
has_one :action_page, :as => actionable
end