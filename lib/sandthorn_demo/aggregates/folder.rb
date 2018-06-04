require 'sandthorn'

module SandthornDemo::Aggregates
    class Folder
        include Sandthorn::AggregateRoot
    
        constructor_events :created
        events :moved, :renamed

        attr_reader :name, :parent_folder_id 
    
        #Constructor
        def self.create name, parent_folder_id = nil
            created(name) do
                @name = name
                @parent_folder_id = parent_folder_id
            end
        end

        def move parent_folder_id
            moved() do
                @parent_folder_id = parent_folder_id
            end
        end

        def rename name
            if @name != name
                renamed() do
                    @name = name
                end
            end
        end
    end
end