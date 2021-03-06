require 'spec_helper'

module SteppingStone
  describe Reporter do
    def setup(name)
      Model::Result.new(inst(:setup, name), :undefined)
    end

    def teardown(name)
      Model::Result.new(inst(:teardown, name), :undefined)
    end

    def dispatch(pattern, status)
      Model::Result.new(inst(:dispatch, pattern), status)
    end

    subject { Reporter.new }

    it "tracks test case results" do
      subject.record(setup("test case 1"))
      subject.record(dispatch("foo", :passed))
      subject.record(teardown("test case 1"))
      subject.record(setup("test case 2"))
      subject.record(dispatch("foo", :failed))
      subject.record(teardown("test case 2"))
      subject.status_of("test case 1").should eq(:passed)
      subject.status_of("test case 2").should eq(:failed)
    end

    it "says if a scenario was undefined" do
      subject.record(setup("undefined"))
      subject.record(dispatch("foo", :undefined))
      subject.record(teardown("undefined"))
      subject.status_of("undefined").should eq(:undefined)
    end

    it "maintains a summary of events" do
      start_time = Time.now
      end_time = start_time + 60
      Timecop.freeze(start_time)
      subject.record_run do
        subject.record(setup("foo"))
        subject.record(dispatch("bar", :passed))
        subject.record(dispatch("baz", :passed))
        subject.record(teardown("foo"))

        subject.record(setup("qux"))
        subject.record(dispatch("quux", :failed))
        subject.record(teardown("qux"))
        Timecop.freeze(end_time)
      end

      subject.summary.should eq({
        start_time:   start_time,
        end_time:     end_time,
        test_cases:   { total: 2, passed: 1, failed: 1, undefined: 0 },
        instructions: { total: 3, passed: 2, failed: 1, undefined: 0, skipped: 0 }
      })
      Timecop.return
    end

    it "notifies observers when it has recieved a new event"
    it "distinguishes between important and unimportant events"
  end
end
