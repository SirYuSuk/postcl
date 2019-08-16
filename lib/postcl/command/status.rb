class Status < PostCL::Command
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
      spin = TTY::Spinner.new("Zending #{barcode} wordt geladen :spinner...", format: :bouncing_ball, clear: true)
      spin.auto_spin
      begin
        resp = PostCL::API.request(barcode, postcode)
        spin.stop()
      rescue PostCL::API::InvalidRequestError
        spin.stop("Ongeldige aanvraag met barcode: #{barcode} en postcode: #{postcode}")
        next
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