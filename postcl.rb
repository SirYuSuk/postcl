#!/usr/bin/env ruby
require_relative 'command.rb'
require_relative 'store.rb'

class PostCL
  def initialize(cli_args)
    ARGV.clear
    if check_flags(cli_args)
      cmd_name = cli_args[1] ? cli_args[1] : "help"
      @args = cli_args.drop(2)
    else
      cmd_name = cli_args[0] ? cli_args[0] : "help"
      @args = cli_args.drop(1)
    end

    @cmd = Command.command(cmd_name.to_sym)
    @store = Store.new("store.yaml")

    # Promt user with package list
    @args = promt_list if flag_set?(:l)

    @cmd.run(@args)
  end

  private

  def check_flags(cli_args)
    return false unless cli_args[0].start_with?("-")
    @flags = cli_args[0].split("").drop(1).map(&:to_sym)
    true
  end

  def flag_set?(flag)
    @flags.include?(flag)
  end

  def promt_list
    p_list = flag_set?(:a) ? @store.packages : @store.undelivered

    error_exit("Geen zendingen in huidige selectie.") unless p_list.size > 0

    puts "Kies een zending:"
    p_list.each_with_index do |p, i|
      puts "[#{i}] #{p['barcode']}, #{p['postcode']}"
    end

    input = nil
    loop do
      print "> "
      input_raw = gets.chomp
      input = input_raw.to_i

      exit 0 if input_raw == "q"

      break unless !input_raw.match(/[0-9]+/) || input < 0 || input >= p_list.size
      puts "Ongeldige invoer!"
    end

    return p_list[input]["barcode"], p_list[input]["postcode"]
  end
end

def error_exit(msg)
  puts msg
  exit 1
end

def arg_error(types, args, index)
  puts "'#{args[index]}' is geen valide #{types[index]}"
  exit 1
end

def check_arguments(types, args)
  args.concat(Array.new(types.size - args.size, "")) unless types.size < args.size

  0.upto(args.size).each do |i|
    case types[i]
    when :barcode
      return i unless args[i].upcase.match(/(3S|KG)[A-Z0-9]{13}/)
    when :postcode
      return i unless args[i].upcase.match(/[0-9]{4}[A-Z]{2}/)
    when :help_commando
      return i unless args[i] == "" || Command.names.include?(args[i].to_sym)
    else
      return i
    end
  end
  -1
end



def run_cmd(cls, args)
  error_i = check_arguments(cls.arg_sig, args)
  arg_error(cls.arg_sig, args, error_i) unless error_i == -1

  cls.run(args)
  exit 0
end

def main
  #check for flags
  if ARGV[0].start_with?("-")
    args = ARGV[1, ARGV.size - 1]
  else
    args = ARGV
  end

  cmd = args[0] || "help"

  cmd_cls = Command.get(cmd.to_sym)
  error_exit("Ongeldig commando. Probeer 'help'.") unless cmd_cls
  run_cmd(cmd_cls, ARGV[1, ARGV.size - 1])
end

if __FILE__ == $0
  PostCL.new(ARGV.dup)
  #main
end