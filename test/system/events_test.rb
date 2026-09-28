require "application_system_test_case"

class EventsTest < ApplicationSystemTestCase
  fixtures [] 

  setup do
    # Generate 30 distinct records through FactoryBot
    # (24 go to Page 1, 6 go to Page 2)
    @events = create_list(:event, 30)
  end

  test "visiting the events page as an authenticated user" do
    # --- PHASE 1: VERIFY THE EVENTS PAGE AS A GUEST ---
    # Verify the initial page content and confirm the user is not authenticated.
    visit events_url

    assert_selector "strong", text: "Billetto Events"
    assert_selector "button", text: "Sign In"

    # Verify that the first batch of events is rendered.
    assert_selector ".event-card", count: 24, wait: 10

    # Scroll to the bottom to trigger lazy loading/infinite scrolling.
    # The additional events should be loaded automatically.
    page.execute_script("window.scrollTo(0, document.body.scrollHeight);")
    assert_selector ".event-card", count: 30, wait: 10


    # --- PHASE 2: SIMULATE CLERK AUTHENTICATION ---
    # Mock the backend Clerk session so Rails treats the user as authenticated.
    ApplicationController.class_eval do
      def clerk_session_user
        OpenStruct.new(id: "user_clerk_bhavik_999")
      end
    end

    # Mock the Clerk client-side object to simulate a successfully
    # authenticated Clerk user without depending on the real Clerk service.
    execute_script <<~JS
      window.Clerk = {
        load: function() { return Promise.resolve(); },
        signOut: function(callback) { callback(); },
        user: {
          id: "user_clerk_bhavik_999",
          firstName: "Bhavik",
          emailAddresses: [{ emailAddress: "bhavik@example.com" }]
        }
      };
    JS

    # Trigger the application's Clerk initialization/authentication logic.
    execute_script("window.dispatchEvent(new Event('load'));")

    # Verify that the authenticated UI is displayed and the guest action is removed.
    assert_text "Signed in as Bhavik", wait: 10
    assert_button "Sign Out"
    assert_no_button "Sign In"


    # --- PHASE 3: VERIFY EVENT VOTING AS AN AUTHENTICATED USER ---
    # Reload the events page so the server-side authenticated state is used.
    visit events_url

    event = @events.first

    within "#event_#{event.id}_voting" do
      # A newly created event should have no likes initially.
      assert_selector ".btn > .fa-thumbs-up", text: "0"

      # Like the event and verify the Turbo response updates the counter.
      find(".btn-outline-primary").click
      assert_selector ".btn > .fa-thumbs-up", text: "1", wait: 10
    end

    within "#event_#{event.id}_voting" do
      # A newly created event should have no dislikes initially.
      assert_selector ".btn > .fa-thumbs-down", text: "0"

      # Dislike the event and verify the Turbo response updates the counter.
      find(".btn-outline-danger").click
      assert_selector ".btn > .fa-thumbs-down", text: "1", wait: 10
    end


    # --- PHASE 4: SIMULATE SIGN OUT ---
    # Replace the Clerk mock with an unauthenticated state.
    # signOut clears the mocked user before invoking the callback,
    # allowing the application's logout handler to update the UI.
    execute_script <<~JS
      window.Clerk = {
        load: function() { return Promise.resolve(); },
        signOut: function(callback) { 
          window.Clerk.user = null;
          callback(); 
        },
        user: { firstName: "Bhavik" }
      };
    JS

    # Re-trigger the Clerk initialization so the application picks up
    # the updated unauthenticated state.
    execute_script("window.dispatchEvent(new Event('load'));")

    # Trigger the application's sign-out action.
    click_button "Sign Out", wait: 10

    # Verify that the UI has returned to the guest state.
    assert_button "Sign In"
    assert_no_text "Signed in as Bhavik"
  end

end
