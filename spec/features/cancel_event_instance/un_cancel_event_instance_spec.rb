RSpec.feature 'Admin un-cancels an event instance', type: :feature do
  before do
    user = Fabricate.create(:user)
    login_as(user, scope: :user)
  end

  scenario 'from the event page' do
    given_an_existing_cancelled_event_instance
    when_i_mark_the_cancelled_date_as_not_cancelled_on_the_event_page
    then_that_date_should_not_be_displayed_as_cancelled
    and_that_date_should_not_be_displayed_as_cancelled_in_the_event_instance_list
  end

  scenario 'from the event page, for a past event instance' do
    given_an_existing_cancelled_event_instance_in_the_past
    when_i_mark_the_cancelled_date_as_not_cancelled_on_the_event_page
    then_that_date_should_not_be_displayed_as_cancelled
    and_that_date_should_not_be_displayed_as_cancelled_in_the_event_instance_list
  end

  # TODO: Would it be better to go through the process of creating an event explicitly?
  def given_an_existing_cancelled_event_instance
    test_instance = Fabricate.create(:event_instance, cancelled: true)

    @event_date = test_instance.date
    @event_name = test_instance.event.name
  end

  def given_an_existing_cancelled_event_instance_in_the_past
    test_instance = Fabricate.build(:event_instance, cancelled: true, date: Faker::Date.backward)
    test_instance.save(validate: false) # need validate: false to create an event in the past

    @event_date = test_instance.date
    @event_name = test_instance.event.name
  end

  def when_i_mark_the_cancelled_date_as_not_cancelled_on_the_event_page
    visit '/events'
    click_link @event_name

    within event_instance_group_on_event_page(@event_date) do
      click_button 'Uncancel'
    end
  end

  def then_that_date_should_not_be_displayed_as_cancelled
    within event_instance_group_on_event_page(@event_date) do
      expect(page).to_not have_content 'Cancelled'
      expect(page).to have_button 'Cancel'
    end
  end

  def and_that_date_should_not_be_displayed_as_cancelled_in_the_event_instance_list
    visit '/event_instances'
    expect(event_instance_group_in_event_instances_list(@event_date)).to_not have_content 'Cancelled'
  end
end
