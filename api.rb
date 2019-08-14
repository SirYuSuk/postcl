require 'httparty'
require 'time'

class API
  class InvalidRequestError < Exception
  end

  def self.API_URI
    "https://jouw.postnl.nl/web/api/default/shipmentStatus/"
  end

  def self.request(b_code, p_code)
    r = HTTParty.get(self.API_URI + b_code + "-NL-" + p_code, format: :plain)
    raise InvalidRequestError if r.code != 200
    stat_dict = JSON.parse r.body, symbolize_names: true
    APIResponse.new(stat_dict)
  end
end

class APIResponse
  def initialize(stat_dict)
    @stat_dict = stat_dict
    @info = stat_dict[:shipments][stat_dict[:barcode].to_sym]
  end

  private

  def format_location(entity)
    "#{entity[:street]} #{entity[:houseNumber]}, #{entity[:postalCode]} #{entity[:town]}"
  end

  def format_name(entity)
    name = "#{entity[]}"
  end

  public

  def stat_dict
    @stat_dict
  end

  def location(mode)
    nil unless mode == :sender || mode == :receiver
    format_location(@info[mode])
  end

  def name(mode)
    nil unless mode == :sender || mode == :receiver
    format_name(@info[mode])
  end

  def stat_index
    @info[:delivery][:phase][:index]
  end

  def stat_msg
    @info[:delivery][:phase][:message]
  end

  def delivered?
    @info[:delivery][:isDelivered]
  end

  def delivery_date
    t = Time.parse(@info[:delivery][:deliveryDate])
    t.strftime("%A %d %B, om %k:%M")
  end
end