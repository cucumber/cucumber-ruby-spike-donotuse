require 'stepping_stone/servers/rb'

module SteppingStone
  # A server's responsibility is to manage test case execution and mapping
  # from natural language actions to code.
  module Servers
    def self.boot!(name=:default, opts={})
      case name
      when :default
        Rb.boot!(opts)
      else
        fail "No server named #{name} has been registered!"
      end
    end
  end
end
