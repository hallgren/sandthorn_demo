require 'spec_helper'
require 'securerandom'

describe "Folder" do

    let(:subject) do
        s = SandthornDemo::Aggregates::Folder.create("Morgan")
        s.save()
        s.extend Sandthorn::EventInspector
        s
    end

    context "created" do

        it "should have Morgan as name" do
            expect(subject.name).to eql "Morgan"
        end

        it "should have nil as parent_folder_id " do
            expect(subject.parent_folder_id).to be_nil
        end

        it "should hold one create event" do
            expect(subject.has_event?(:created)).to be_truthy
        end
    end

    context "moved" do
        
        let(:parent_folder_id) do
            SecureRandom.uuid
        end

        before do
            subject.move(parent_folder_id)
            subject.save()
        end

        it "should have new parent_folder_id" do
            expect(subject.parent_folder_id).to eql parent_folder_id
        end

        it "should hold one moved event" do
            expect(subject.has_event?(:moved)).to be_truthy
        end

    end

    context "renamed" do
        
        let(:new_name) do
            "Olle"
        end

        before do
            subject.rename(new_name)
            subject.save()
        end

        it "should have new name" do
            expect(subject.name).to eql new_name
        end

        it "should hold one renamed event" do
            expect(subject.has_event?(:renamed)).to be_truthy
        end

    end

end
