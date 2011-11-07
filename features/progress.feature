Feature: Showing the progress of a test run

  Cucumber gives an indication of its progress
  as it executes scenarios.

  Background:
    Given a scenario with:
      """
      Given a step
      """

  Scenario: 1 passing
    Given I'm using the progress formatter
    And all of the steps in the scenario pass
    When Cucumber executes the scenario
    Then the progress output looks like:
      """
      .

      1 scenario (1 passed)
      1 step (1 passed)

      """

  Scenario: 1 failing
    Given I'm using the progress formatter
    And all of the steps in the scenario fail
    When Cucumber executes the scenario
    Then the progress output looks like:
      """
      F

      1 scenario (1 failed)
      1 step (1 failed)

      """
