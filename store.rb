require_relative 'api.rb'

require 'fileutils'
require 'yaml'

class Store
  def initialize(name = "store.yaml", dir = "#{File.expand_path('~')}/.config/postcl/")
    @dir = dir
    @path = dir + name
    load

  end

  private

  def load
    begin
      @data = YAML.load(File.open(@path))
    rescue Errno::ENOENT
      FileUtils.mkdir_p(@dir)
      @data = { postcode: nil, packages: [] }
      save
    end
  end

  def save
    File.open(@path, "w") { |f| f.write(@data.to_yaml) }
  end

  public

  def add(resp)
    p_elem = {
      barcode: resp.info[:barcode],
      postcode: resp.info[:postalCode],
      undelivered: resp.info[:delivery][:isDelivered]
      }
    @data[:packages] << p_elem
    save
  end

  def postcode
    @data[:postcode]
  end

  def postcode=(postcode)
    @data[:postcode] = postcode
    save
  end

  def packages
    @data[:packages]
  end

  def filter(f_proc)
    @data[:packages].select(&f_proc)
  end

  def undelivered
    filter(proc { |p| p[:undelivered] })
  end

  def package(barcode, postcode)
    filter(proc { |p| p[:barcode].upcase == barcode.upcase && p[:postcode].upcase == postcode.upcase })[0]
  end

  def include?(barcode, postcode)
    package(barcode, postcode) != nil
  end

  def prompt_add(resp)
    if TTY::Prompt.new.yes?("Het lijkt er op dat deze zending nog niet is opgeslagen, wilt u hem toevoegen?")
      add(resp)
    end
  end
end
