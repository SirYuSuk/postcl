require_relative 'api.rb'

require 'colorize'
require 'terminal-table'

class Command
  def self.usage
    "postcl #{self.cmd_name} #{self.arg_sig.join(" ")}"
  end

  class << self
    attr_reader :arg_sig, :desc, :cmd_name
  end

  def self.names
    ObjectSpace.each_object(Class).select { |c| c < Command }.map!(&:cmd_name)
  end

  def self.command(name)
    cmds = ObjectSpace.each_object(Class).select { |c| c < Command }
    cmds.find { |c| c.cmd_name == name }
  end
end


class Status < Command
  @cmd_name = :status
  @arg_sig = [:barcode, :postcode]
  @desc = "Geeft de huidige verzendstatus van het gegeven pakketje weer."

  def self.run(args)
    b_code, p_code = args
    resp = API.request(b_code, p_code)
    puts "Van " + resp.location(:sender).red +
         " naar " + resp.location(:receiver).green
  end
end

class Info < Command
  @cmd_name = :info
  @arg_sig = [:barcode, :postcode]
  @desc = "Geeft de huidige verzendstatus van het gegeven pakketje weer."

  def self.run(args)
    b_code, p_code = args
    stat_dict = API.request(b_code, p_code)
    puts JSON.pretty_generate(stat_dict)
  end
end


class Help < Command
  @cmd_name = :help
  @arg_sig = [:help_commando]
  @desc = "Geeft info over het gegeven commando."

  private
  def self.cmd_info(cmd)
    Command.get(cmd).desc
  end

  def self.cmd_usage(cmd)
    Command.get(cmd).usage
  end

  public
  def self.run(args)
    cmd = args[0].to_sym
    if cmd != :""
      puts "[#{self.cmd_usage(cmd)}]"
      puts "#{self.cmd_info(cmd)}".red
    else
      puts " Beschikbare commando's:"
      puts "========================="
      Command.names.each do |cmd|
        puts " * #{cmd}".bold
        puts "      [#{self.cmd_usage(cmd)}]"
        puts "      #{self.cmd_info(cmd)}".red
      end
    end
  end
end

class Volg < Command
  @cmd_name = :info
  @arg_sig = [:barcode, :postcode]
  @desc = "Voegt een nieuw pakket toe aan de lijst van te-volgen zendingen"

  def self.run(args)
    b_code, p_code = args
    stat_dict = API.request(b_code, p_code)
    puts JSON.pretty_generate(stat_dict)
  end
end