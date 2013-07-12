require 'liars_dice/watcher'
require 'liars_dice/bid'
require 'liars_dice/engine'
require 'liars_dice/event'
require 'liars_dice/game'
require 'liars_dice/seat'
require 'liars_dice/command_line_watcher'
Dir[File.dirname(__FILE__) + '/liars_dice/bots/*.rb'].each {|file| require file }
