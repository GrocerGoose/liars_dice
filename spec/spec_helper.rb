gem 'rspec'
require 'ostruct'

require 'liars_dice'

RSpec.configure do |c|
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true
end
