require "sandthorn_sequel_projection"

module SandthornDemo::Projections
    class FolderNames < SandthornSequelProjection::Projection

        # Start by defining any needed migrations.
        # See SimpleMigrator::Migratable for details
        migration("FolderNamesProjection20180605-1") do |db_connection|
            db_connection.create_table?(table_name) do
                string      :id
                string      :name
            end
        end
        
        # Event handlers will be executed in the order they were defined
        # The key is the name of the method to be executed. Filters are defined in the value.
        # Handlers with only a symbol will execute for all events.
        define_event_handlers do |handlers|
            handlers.define created: { aggregate_type: SandthornDemo::Aggregates::Folder, event_name: :created }
            handlers.define renamed: { aggregate_type: SandthornDemo::Aggregates::Folder, event_name: :renamed }
        end 
        
        #Queries
        def all
            table.all
        end

        private

        def created(event)
            # handle created folder events, one at a time
            db_connection.transaction do
                table.insert(name: event[:event_data][:name][:new_value], id: event[:aggregate_id])
            end
        end
        
        def renamed(event)
            # update the name of the folder in the db
            db_connection.transaction do
                table.where(id: event[:aggregate_id]).update(name: event[:event_data][:name][:new_value])
            end
        end

        def table
            db_connection[table_name]
          end
      
        def table_name
            :folder_names
        end
    end
end