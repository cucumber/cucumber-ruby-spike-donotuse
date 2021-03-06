require 'spec_helper'

module SteppingStone
  module Observers
    describe EventLog do
      subject { EventLog.new(Reporter.new) }

      def ev(event, status)
        Model::Result.new(inst(event, []), status)
      end

      before do
        subject.add(ev(:setup, :passed))
        subject.add(ev(:dispatch, :passed))
        subject.add(ev(:dispatch, :undefined))
        subject.add(ev(:dispatch, :skipped))
        subject.add(ev(:teardown, :failed))
      end

      describe "#events" do
        it "includes all events" do
          subject.should have(5).events
        end

        it "filters events" do
          subject.events(status: :passed).length.should eq(2)
          subject.events(name: :dispatch).length.should eq(3)
        end
      end

      describe "#history" do
        it "includes important events" do
          subject.history.should have(5).events
          subject.history.each do |event|
            event.should be_important
          end
        end

        it "excludes unimportant events" do
          unimportant = ev(:setup, :undefined)
          subject.add(unimportant)
          subject.history.should_not include(unimportant)
        end
      end

      describe "#add" do
        let(:event) { Model::Result.new(inst(:event, []), :passed) }

        it "adds the event to the log" do
          subject.add(event)
          subject.events.should include(event)
        end
      end

      describe "#each" do
        it "iterates through all the events" do
          events = []
          subject.each { |e| events << e }
          events.map(&:name).should eq([:setup, :dispatch, :dispatch, :dispatch, :teardown])
        end
      end
    end
  end
end
