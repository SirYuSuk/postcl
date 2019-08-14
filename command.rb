require_relative 'api.rb'

require 'colorize'
require 'terminal-table'
require 'tty-prompt'

class Command
  @@ARG_MATCH = {
    barcode: /(3S|KG)[A-Z0-9]{13}/,
    postcode: /[0-9]{4}[a-zA-Z]{2}/
  }

  def initialize(post)
    @args = post.args
    @prompt = post.prompt
    @store = post.store
  end

  class UnknownCommandError < Exception
  end

  def self.validate_args(args)
    args.each_key do |key|
      key_sym = key[1...-1].to_sym
      if @@ARG_MATCH.keys.include?(key_sym)
        args[key].each do |arg|
          next if arg.match(@@ARG_MATCH[key_sym])
          puts "Ongeldige #{key_sym}: #{arg}"
          exit 1
        end
      end
    end
  end

  def self.run(post)
    if post.args["status"]
      Status.new(post).run
    elsif post.args["info"]
      Info.new(post).run
    else
      raise UnknownCommandError
    end
  end
end

class Status < Command
  @@ART = {
    1 => ["  __________", " |\\    \\    \\", " | \\____\\____\\", " | |      ~~ |", " \\ |         |", "  \\|_________|"],
    2 => ["   __________", "  |       ~~ |", "--|          |--", "  |__________|", "================", "  ( )  ( )  ( )"],
    3 => ["  _________", " |       |_\\", " |PostNL    \\___", " |              |", "  --( )-----( )-", ""],
    4 => ["   _________H", "  /\\         \\", " /  \\         \\", " |  |    _    |", " |  |[] | | []|", " `-_|   |`|   |"],
  }

  def initialize(post)
    super(post)
  end

  private

  def stat_info(row, resp)
    case row
    when 1
      return resp.stat_msg.bold
    when 2
      if resp.delivered?
        return "Bezorgd op: #{resp.delivery_date}"
      else
        return "Bezorging verwacht op: "
      end
    when 3
      return "Bestemming: #{resp.location(:receiver)}"
    else
      return ""
    end
  end

  public

  def run
    @args["<barcode>"].zip(@args["<postcode>"]).each do |barcode, postcode|
      begin
        resp = API.request(barcode, postcode)
      rescue API::InvalidRequestError
        puts "Ongeldige aanvraag met barcode: #{barcode} en postcode: #{postcode}"
        exit 1
      end

      @store.prompt_add(resp) unless @store.include?(barcode, postcode) || @args["-n"]

      puts "Status van zending: " + barcode.bold
      stat_banner = Array(6)
      art = @@ART[resp.stat_index]
      (0..5).each do |i|
        stat_banner[i] = art[i].ljust(20, " ") + stat_info(i, resp)
      end
      puts stat_banner.join("\n")
      # puts "Van " + resp.location(:sender).red +
          #  " naar " + resp.location(:receiver).green
      puts
    end
  end
end

class Info < Command
  def initialize(post)
    super(post)
  end

  def run
    puts "info"
  end
end

# class Command
#   def self.usage
#     "postcl #{self.cmd_name} #{self.arg_sig.join(" ")}"
#   end

#   class << self
#     attr_reader :arg_sig, :desc, :cmd_name
#   end

#   def self.names
#     ObjectSpace.each_object(Class).select { |c| c < Command }.map!(&:cmd_name)
#   end

#   def self.command(name)
#     cmds = ObjectSpace.each_object(Class).select { |c| c < Command }
#     cmds.find { |c| c.cmd_name == name }
#   end
# end


# class Status < Command
#   @cmd_name = :status
#   @arg_sig = [:barcode, :postcode]
#   @desc = "Geeft de huidige verzendstatus van het gegeven pakketje weer."

#   def self.run(args)
#     b_code, p_code = args
#     resp = API.request(b_code, p_code)
#     puts "Van " + resp.location(:sender).red +
#          " naar " + resp.location(:receiver).green
#   end
# end

# class Info < Command
#   @cmd_name = :info
#   @arg_sig = [:barcode, :postcode]
#   @desc = "Geeft de huidige verzendstatus van het gegeven pakketje weer."

#   def self.run(args)
#     b_code, p_code = args
#     stat_dict = API.request(b_code, p_code)
#     puts JSON.pretty_generate(stat_dict)
#   end
# end


# class Help < Command
#   @cmd_name = :help
#   @arg_sig = [:help_commando]
#   @desc = "Geeft info over het gegeven commando."

#   private
#   def self.cmd_info(cmd)
#     Command.command(cmd).desc
#   end

#   def self.cmd_usage(cmd)
#     Command.command(cmd).usage
#   end

#   public
#   def self.run(args)
#     cmd = args[0].to_sym unless args.empty?
#     if cmd
#       puts "[#{self.cmd_usage(cmd)}]"
#       puts "#{self.cmd_info(cmd)}".red
#     else
#       puts " Beschikbare commando's:"
#       puts "========================="
#       Command.names.each do |cmd|
#         puts " * #{cmd}".bold
#         puts "      [#{self.cmd_usage(cmd)}]"
#         puts "      #{self.cmd_info(cmd)}".red
#       end
#     end
#   end
# end

# class Volg < Command
#   @cmd_name = :info
#   @arg_sig = [:barcode, :postcode]
#   @desc = "Voegt een nieuw pakket toe aan de lijst van te-volgen zendingen"

#   def self.run(args)
#     b_code, p_code = args
#     stat_dict = API.request(b_code, p_code)
#     puts JSON.pretty_generate(stat_dict)
#   end
# end