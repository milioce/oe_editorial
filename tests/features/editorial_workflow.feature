@api
Feature: Corporate editorial workflow
  As a content editor
  I can moderate content through different states by different roles

  Scenario: As an Author user, I can create a Draft demo content and I can send it for Needs Review.
    Given I am logged in as a user with the "Author" role
    When I visit "the demo content creation page"
    Then I should have the following options for the "Save as" select:
      | Draft |
    When I fill in "Title" with "Workflow demo"
    And I press "Save"
    And I visit "the content administration page"
    # The content is created and it is not published.
    Then I should see the text "not published" in the "Workflow demo" row
    When I click "Workflow demo"
    Then the current workflow state should be "Draft"
    # Check that the only available next state is Needs Review.
    Then I should have the following options for the "Change to" select:
      | Needs Review |
    # After setting it to Needs Review the Author can edit the node but only to draft.
    When I select "Needs Review" from "Change to"
    And I press "Apply"
    Then I should see the link "Edit"
    When I click "Edit"
    Then I should have the following options for the "Change to" select:
      | Draft |

  Scenario: As a Reviewer user, I can moderate demo content by send it back to Draft or to Request Validation.
    Given I am logged in as a user with the "Reviewer" role
    And "oe_workflow_demo" content:
      | title         | moderation_state |
      | Workflow node | needs_review     |
    And I visit "the content administration page"
    When I click "Workflow node"
    # We are on the node view page and we see the current state is Needs Review and we can't edit.
    Then I should not see the link "Edit"
    And the current workflow state should be "Needs Review"
    And I should have the following options for the "Change to" select:
      | Draft              |
      | Request Validation |
    # After Request Validation I have no Moderation access.
    When I select "Request Validation" from "Change to"
    And I press "Apply"
    Then I should not see "Change to"

  Scenario: As a Validator user, I can moderate demo content by send it back to Draft or to Needs Review, or validate.
    Given I am logged in as a user with the "Validator" role
    And "oe_workflow_demo" content:
      | title         | moderation_state   |
      | Workflow node | request_validation |
    And I visit "the content administration page"
    When I click "Workflow node"
    # We are on the view page and we see the current state is Request Validation and we can't edit.
    Then I should not see the link "Edit"
    And the current workflow state should be "Request Validation"
    And I should have the following options for the "Change to" select:
      | Draft        |
      | Needs Review |
      | Validated    |
    When I select "Validated" from "Change to"
    And I press "Apply"
    # Once the content is validated only author can initiate a Draft state.
    Then I should have the following options for the "Change to" select:
      | Published |
    When I select "Published" from "Change to"
    And I press "Apply"
    Then I should not see the link "New draft"
    And I should not see "Change to"

  Scenario: As an Author user, I can Publish a Validated demo content.
    Given users:
      | name        | roles  |
      | author_user | Author |
    And "oe_workflow_demo" content:
      | title         | moderation_state | author      |
      | Workflow node | validated        | author_user |
    And I am logged in as "author_user"
    When I visit "the content administration page"
    # The content is created and it is not published.
    Then I should see the text "not published" in the "Workflow node" row
    When I click "Workflow node"
    And I click "Edit"
    # After validation I have Edit access and I can publish the node.
    Then I should have the following options for the "Change to" select:
      | Draft |
    When I click "View"
    Then I should have the following options for the "Change to" select:
      | Draft     |
      | Published |
    When I select "Published" from "Change to"
    And I press "Apply"
    And I click "New draft"
    # After Publish I can restart the workflow.
    Then I should have the following options for the "Change to" select:
      | Draft |
    # The content is created and it is published.
    When I visit "the content administration page"
    Then I should see text matching "published"
    And I should not see text matching "not published"

  Scenario: As an Author user, I can create new draft for published content.
    Given users:
      | name        | roles  |
      | author_user | Author |
    And "oe_workflow_demo" content:
      | title         | moderation_state | author      |
      | Workflow node | published        | author_user |
    And I am logged in as "author_user"
    When I visit "the content administration page"
    # The content is created and it is published.
    Then I should see the text "published" in the "Workflow node" row
    When I click "Workflow node"
    And I click "New draft"
     # After Publish I can restart the workflow and Edit draft to draft.
    Then I should have the following options for the "Change to" select:
      | Draft |
    When I select "Draft" from "Change to"
    And I press "Save"
    And I should see "Edit draft"
    When I visit "the content administration page"
    # The content is created and it is published.
    Then I should see text matching "published"
    And I should not see text matching "not published"

  Scenario: As an Author user, I can see the node revisions.
    Given I am logged in as a user with the "Author" role
    And I visit "the demo content creation page"
    And I fill in "Title" with "Workflow demo"
    And I press "Save"
    When I select "Needs Review" from "Change to"
    And I press "Apply"
    And I click Revisions
    Then I should see "Revisions for Workflow demo"

  Scenario: As a user with combined roles I can edit and publish a node and I can revert revisions.
    Given I am logged in as a user with the "Author, Reviewer, Validator" roles
    And I visit "the demo content creation page"
    And I fill in "Title" with "Workflow demo"
    And I press "Save"
    When I select "Needs Review" from "Change to"
    And I press "Apply"
    Then I should see the link "Edit"
    When I select "Request Validation" from "Change to"
    And I press "Apply"
    Then I should see the link "Edit"
    When I select "Validated" from "Change to"
    And I press "Apply"
    Then I should see the link "Edit"
    # Node is in published state.
    And I select "Published" from "Change to"
    And I press "Apply"
    When I click Revisions
    And I click Revert
    # Confirmation page.
    Then I should see "Are you sure you want to revert to the revision"

  Scenario: As a Author and Validator user, I can move published content to Archived or Expired.
    Given users:
      | name        | roles             |
      | author_user | Author, Validator |
    And "oe_workflow_demo" content:
      | title         | moderation_state | author      |
      | Workflow node | published        | author_user |
    And I am logged in as "author_user"
    When I visit "the content administration page"
    And I click "Workflow node"
    And I click "New draft"
    Then I should have the following options for the "Change to" select:
      | Draft    |
      | Archived |
      | Expired  |

  Scenario: As an Author, when node has only published revision I see "New draft"
  and when a node has new draft after the published revision I see "Edit draft" on the node tabs.
    Given users:
      | name        | roles  |
      | author_user | Author |
    And "oe_workflow_demo" content:
      | title         | moderation_state | author      |
      | Workflow node | published        | author_user |
    And I am logged in as "author_user"
    When I visit "the content administration page"
    And I click "Workflow node"
    And I click "New draft"
    Then I should have the following options for the "Change to" select:
      | Draft |
    When I select "Draft" from "Change to"
    And I press "Save"
    And I should see "Edit draft"

  Scenario: Permission to delete content is not given to any editorial role.
    Given users:
      | name        | roles                                   |
      | author_user | Author, Reviewer, Validator, Translator |
    And "oe_workflow_demo" content:
      | title         | moderation_state | author      |
      | Workflow node | draft            | author_user |
    And I am logged in as "author_user"
    When I visit "the content administration page"
    And I click "Workflow node"
    Then I should not see "Delete"

  Scenario: Node has "View published" or "View draft" tab instead of "View" tab.
    Given users:
      | name        | roles  |
      | author_user | Author, Validator |
    And "oe_workflow_demo" content:
      | title         | moderation_state | author      |
      | Workflow node | validated        | author_user |
    And I am logged in as "author_user"
    When I visit "the content administration page"
    And I click "Workflow node"
    Then I should see "View draft"
    And I should not see "View published"
    When I select "Published" from "Change to"
    And I press "Apply"
    Then I should see "View published"
    And I should not see "View draft"
