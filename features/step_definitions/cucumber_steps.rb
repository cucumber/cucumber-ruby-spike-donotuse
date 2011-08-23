Given /^a passing scenario "(.+)" with:$/ do |name, body|
  @test_case = compile_scenario(name, body, @background)
end

Given /^a passing background with:$/ do |background|
  @background = background
end

Given /^these passing hooks:$/ do |hooks|
  hooks.rows.each do |aspect, subject|
    add_hook(aspect, subject, :pass)
  end
end

Given "there are no hooks" do
  sut.hooks.should be_empty
end

When /^Cucumber executes the scenario "(.+)"$/ do |name|
  execute(@test_case)
end

Then /^the life cycle history is:$/ do |table|
  table.map_column!(:event, &:to_sym)
  table.map_column!(:status, &:to_sym)
  table.map_column!(:name) { |name| [name] }
  life_cycle_history.should eq(table.rows)
end

module CucumberWorld
  def compile_scenario(name, body, background=nil)
    feature = build_feature(name, body, background)
    if test_cases = SteppingStone::GherkinCompiler.new.compile(feature)
      test_cases[0]
    else
      raise "Something when wrong while compiling #{body}"
    end
  end

  def build_feature(name, body, background=nil)
    out = "Feature: test\n"
    out << "Background:\n #{background}\n" if background
    out << "Scenario: #{name}\n#{body}"
  end

  def define_mapper(sut)
    Module.new do
      extend sut.dsl_module
      include RSpec::Matchers

      def_map /I log in as "(\w+)"/ => :login_as
      def_map "I add 4 and 5" => :add
      def_map "the result is 9" => :assert_result

      def login_as(userid)
        @userid = userid
      end

      def add
        @result = 5 + 4
      end

      def assert_result
        @result.should eq(9)
      end
    end
  end

  def add_hook(aspect, subject, result)
    # subject isn't used for anything yet
    hook = SteppingStone::TextMapper::Hook.new([aspect.to_sym, {}]) { |test_case| result }
    sut.add_mapping(hook)
  end

  def sut
    @sut ||= SteppingStone::Servers::Rb.new
  end

  def reporter
    @reporter ||= SteppingStone::Reporter.new(sut)
  end

  def executor
    @executor ||= SteppingStone::Model::Executor.new(reporter)
  end

  def execute(test_case)
    executor.execute(test_case)
  end

  def life_cycle_history
    reporter.history.map(&:to_a)
  end
end

Before do
  define_mapper(sut)
end

World(CucumberWorld)
