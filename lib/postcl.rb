require 'colorize'
require 'fileutils'
require 'httparty'
require 'time'
require 'tty-prompt'
require 'tty-spinner'
require 'yaml'

module PostCL
  class Session
    attr_reader :args, :store, :prompt

    def initialize(doc_parse)
      @args = doc_parse
      @prompt = TTY::Prompt.new
      @store = Store.new(self)

      @store.promt_list if @args["--lijst"]

      Command.validate_args(@args)

      begin
        Command.run(self)
      rescue Command::UnknownCommandError
        puts "ongelding commando"
      end
    end

    def error_exit(msg)
      puts msg
      exit 1
    end
  end

  require_relative 'postcl/api'
  require_relative 'postcl/command'
  require_relative 'postcl/store'
  require_relative 'postcl/version'
end
