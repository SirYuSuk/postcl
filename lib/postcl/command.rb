

class PostCL::Command
  ARG_MATCH = {
    barcode: /(3S|KG)[A-Z0-9]{13}/,
    postcode: /[0-9]{4}[a-zA-Z]{2}/
  }

  class UnknownCommandError < Exception
  end

  def initialize(session)
    @args = session.args
    @prompt = session.prompt
    @store = session.store
  end

  def self.validate_args(args)
    args.each_key do |key|
      key_sym = key[1...-1].to_sym
      if ARG_MATCH.keys.include?(key_sym)
        args[key].each do |arg|
          next if arg.match(ARG_MATCH[key_sym])
          puts "Ongeldige #{key_sym}: #{arg}"
          exit 1
        end
      end
    end
  end

  def self.run(session)
    if session.args["status"]
      Status.new(session).run
    # elsif post.args["info"]
    #   Info.new(post).run
    elsif post.args["volg"]
      Volg.new(session).run
    else
      raise UnknownCommandError
    end
  end
end

# Require all Command classes
Dir["#{File.expand_path("lib/postcl/command/")}/*.rb"].each { |f| require f }
