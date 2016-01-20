ActiveRecord::Base.configurations[Rails.env].merge!(prepared_statements: false)
