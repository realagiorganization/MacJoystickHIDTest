Feature: View joystick HID test landing page
  As a visitor
  I want to preview the Mac Joystick HID Test page
  So that I understand what the utility provides

  Scenario: Hero section presents key actions
    Given I open the docs page
    Then I see the heading "Joystick HID Test"
    And I see a call-to-action button labeled "Get the App"
    And I see a secondary button labeled "How It Works"

  Scenario: Sections describe capabilities
    Given I open the docs page
    Then I see a section titled "Built for quick diagnostics"
    And I see a section titled "Grab the source, ship the build"
    And I see a section titled "Interface preview"

  Scenario: Interface preview image loads
    Given I open the docs page
    When I wait for the preview image
    Then the preview image is visible
