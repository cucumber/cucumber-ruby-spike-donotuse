require 'spec_helper'

module SteppingStone
  describe HookList do
    describe "#invoke" do
      it "invokes hooks after composing them" do
        results = []
        subject.before { results.push(:before) }
        subject.after { results.push(:after) }
        subject.around do |run|
          results.push(:around_before)
          run.call
          results.push(:around_after)
        end
        subject.invoke { results.push(:run) }
        results.should eq([:around_before, :before, :run, :after, :around_after])
      end
    end
  end
end
