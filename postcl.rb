#!/usr/bin/env ruby
require_relative 'command.rb'
require_relative 'store.rb'

require 'awesome_print'
require 'docopt'
require 'tty-prompt'


doc = <<DOCOPT
PostCL

Usage:
  postcl (info|status) [-n] (<barcode> <postcode>)...
  postcl (info|status) -p [-n] <barcode>...
  postcl (info|status) -l [-a]
  postcl (info|status) -e
  postcl -h | --help
  postcl -v

Options:
  -a --alles
  -l --lijst
  -e --eerstvolgende
  -h --help
  -v

DOCOPT

class PostCL
  @@VERSION = "0.1"

  attr_reader :args, :store, :prompt

  def initialize(doc_parse)
    @args = doc_parse
    @store = Store.new()
    @prompt = TTY::Prompt.new

    promt_list if arg_set?("--lijst")

    Command.validate_args(@args)

    begin
      Command.run(self)
    rescue Command::UnknownCommandError
      puts "ongelding commando"
    end
  end

  private

  def error_exit(msg)
    puts msg
    exit 1
  end

  def arg_set?(name)
    @args[name]
  end

  def promt_list
    p_list = arg_set?("--alles") ? @store.packages : @store.undelivered

    error_exit("Geen zendingen in huidige selectie.") unless p_list.size > 0

    choices = []
    p_list.each_with_index do |p, i|
      choices << {name: "#{p[:barcode]}, #{p[:postcode]}", value: i}
    end
    input = @prompt.multi_select("Selecteer een of meerdere zendingen:", choices)
    input.each do |i|
      @args["<barcode>"] << p_list[i][:barcode]
      @args["<postcode>"] << p_list[i][:postcode]
    end
  end

  def promt_postcode

  end

  def self.VERSION
    @@VERSION
  end
end

if __FILE__ == $0
  begin
    doc_parse =  Docopt::docopt(doc, version: PostCL.VERSION)
  rescue Docopt::Exit => e
    puts e.message
    exit 1
  end

  # Otherwise gets won't work
  ARGV.clear

  PostCL.new(doc_parse)
end