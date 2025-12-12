Feature: Initialize TypeWeaver
  As a Ruby developer
  I want to initialize TypeWeaver in my project
  So that I can start generating type signatures

  Scenario: Initialize with default settings
    Given I am in a Ruby project directory
    When I run "typeweaver init"
    Then the output should contain "Initializing TypeWeaver"
    And a directory named ".typeweaver" should exist
    And a file named ".typeweaver/config.json" should exist
    And the file ".typeweaver/config.json" should contain "output_formats"

  Scenario: Initialize with RBI only
    Given I am in a Ruby project directory
    When I run "typeweaver init --format=rbi"
    Then the file ".typeweaver/config.json" should contain '"rbi"'
    And the file ".typeweaver/config.json" should not contain '"rbs"'

  Scenario: Initialize with RBS only
    Given I am in a Ruby project directory
    When I run "typeweaver init --format=rbs"
    Then the file ".typeweaver/config.json" should contain '"rbs"'
    And the file ".typeweaver/config.json" should not contain '"rbi"'
