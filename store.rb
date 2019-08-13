require_relative 'api.rb'

require 'yaml'

class Store
  def initialize(path = "store.yaml")
    @path = path
    load

  end

  private

  def load
    data = YAML.load(File.open(@path))
    @packages = data["packages"]
  end

  def add
  end

  public

  def packages
    @packages
  end

  def filter(f_proc)
    @packages.select(&f_proc)
  end

  def undelivered
    filter(proc { |p| p["undelivered"] })
  end

  def package(barcode, postcode)
    filter(proc { |p| p["barcode"] == barcode && p["postcode"] == postcode })
  end
end
