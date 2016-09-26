require 'rails_helper'

RSpec.describe Event, 'Associations', type: :model do
  it { should have_many(:event_seeds) }
  it { should have_many(:event_periods) }
  it { should have_many(:event_instances) }
end

RSpec.describe Event, type: :model do
  it_should_behave_like 'sortable'

  describe 'name' do
    it 'delegates to the latest event seed' do
      event = Event.create!
      Fabricate.create(:event_seed, name: 'Swing Deluxe', event: event)
      Fabricate.create(:event_seed, name: 'Swing Super Deluxe', event: event)
      expect(event.name).to eq 'Swing Super Deluxe'
    end
  end
end
