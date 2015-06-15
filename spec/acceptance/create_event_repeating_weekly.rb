require 'rails_helper'

RSpec.feature "Admin adds an event", type: :feature do
  scenario "which repeats weekly" do
    Timecop.freeze(Date.new(2001, 1, 1)) do
      given_an_existing_venue
      when_i_create_a_weekly_repeating_event
      then_events_for_the_next_4_weeks_should_be_displayed
      and_events_for_the_next_4_weeks_should_be_displayed_on_the_event_page
    end
  end

  # STEPS:
  ############################################################

  def when_i_create_a_weekly_repeating_event
    visit '/events/new'

    @event_name       = Faker::Company.name
    @event_url        = Faker::Internet.url
    @event_start_date = Date.new(2001, 1, 3)
    @event_frequency  = 'Weekly'

    within("#new_event") do
      fill_in_event_form
      select @existing_venue.name, from: venue_select
      click_button 'Create event'
    end
  end

  def then_events_for_the_next_4_weeks_should_be_displayed
    expect(page).to have_content("New event created"
              ).and have_content("4 instances created"
              )
    display_4_events
  end

  def and_events_for_the_next_4_weeks_should_be_displayed_on_the_event_page
    visit "/events"
    click_link @event_name
    expect(page).to have_link("2001-01-03", href: @event_url
              ).and have_link("2001-01-10", href: @event_url
              ).and have_link("2001-01-17", href: @event_url
              ).and have_link("2001-01-24", href: @event_url
              )
    display_4_events
  end

  def and_events_for_the_next_4_weeks_should_show_in_the_event_instance_list
    visit '/event_instances'
    expect(page).to have_content(@event_url, count: 4)
    display_4_events
  end

  # HELPERS:
  ############################################################

  def display_4_events
    expect(page).to have_content("2001-01-03"
              ).and have_content("2001-01-10"
              ).and have_content("2001-01-17"
              ).and have_content("2001-01-24"
              )
  end

end
