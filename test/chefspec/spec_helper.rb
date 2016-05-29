require 'chefspec'

RSpec.configure do |cfg|
  cfg.cookbook_path = '../../cookbooks/'

  # If there are issues and you need better debugging, change this
  cfg.log_level = :warn
end
