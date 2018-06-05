require "sandthorn_demo/version"
require "sandthorn_demo/aggregates/folder"
require "sandthorn_demo/projections/folder_names"

require "sandthorn"
require "sandthorn_driver_sequel"
require "sandthorn_sequel_projection"
require "oj"

module SandthornDemo
  event_url = "sqlite://event.sqlite3"
  projection_url = "sqlite://projection.sqlite3"

  SandthornDriverSequel.migrate_db url: event_url

  driver = SandthornDriverSequel.driver_from_url(url: event_url) do |conf|
    conf.event_serializer       = Proc.new { |data| Oj::dump(data) }
    conf.event_deserializer     = Proc.new { |data| Oj::load(data) }
  end

  Sandthorn.configure do |c|
    c.event_store = driver
  end

  #Setup an event_store from SanthornDriverSequel
  projection_connection = Sequel.connect(projection_url)
  SandthornSequelProjection.configure do |thorn|
    thorn.db_connection = projection_connection
    thorn.event_store = driver
  end
end
