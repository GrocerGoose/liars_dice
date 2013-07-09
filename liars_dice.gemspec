Gem::Specification.new do |gem|
  gem.name = 'liars_dice'
  gem.version = '0.0.4'
  gem.date = '2013-07-09'
  gem.summary = "Liar's Dice game"
  gem.description = "A liar's dice botting environment, developed by Aisle50"
  gem.authors = ['Ben Schmeckpeper', 'Chris Doyle', 'Max Page', 'Molly Struve']
  gem.email = 'dev@aisle50.com'

  exclusions = [".rvmrc"]
  gem.files               = `git ls-files`.split($\) - exclusions
  gem.test_files          = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths       = ["lib"]
end
