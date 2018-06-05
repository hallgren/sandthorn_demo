require 'spec_helper'

describe SandthornDemo::Projections::FolderNames do
    let(:projection) do
        SandthornDemo::Projections::FolderNames.new
    end

    before(:each) do
        f = SandthornDemo::Aggregates::Folder.create("Morgan")
        f.save()

        f2 = SandthornDemo::Aggregates::Folder.create("Tom")
        f2.save()
        
        projection.migrate!
        projection.update!
    end

    context "names" do
        it "should hold 2 names" do    
            expect(projection.all.length).to eql 2
        end

        it "should contain one item with name Morgan" do
            expect(projection.all.select { |item| item[:name] == "Morgan"}.length).to eq 1
        end
    end
end