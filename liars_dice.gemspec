Gem::Specification.new do |gem|
  gem.name = 'liars_dice'
  gem.version = '0.0.6'
  gem.date = '2013-07-12'
  gem.summary = "Liar's Dice game"
  gem.description = "A liar's dice botting environment, developed by Aisle50"
  gem.authors = ['Ben Schmeckpeper', 'Chris Doyle', 'Max Page', 'Molly Struve']
  gem.email = 'dev@aisle50.com'

  exclusions = %w{ .rvmrc }
  included_bots = %w{ lib/liars_dice/bots/human_bot.rb lib/liars_dice/bots/random_bot.rb }
  gem.files               = `git ls-files`.split($\) + included_bots - exclusions
  gem.test_files          = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths       = ["lib"]
end
