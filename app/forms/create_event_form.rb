class CreateEventForm
  include ActiveModel::Model

  def persisted?
    false
  end

  delegate :name, to: :event
  delegate :url, :venue_id, to: :event_seed
  delegate :venue, :build_venue, to: :event_seed
  delegate :frequency, :start_date, to: :event_generator


  class << self
    # Required to make the venue form work (via cocoon)
    delegate :reflect_on_association, to: EventSeed
  end

  attr_reader :success_message

  validates :name, presence: true
  validates :url, presence: true, url: { allow_blank: true }
  validates :venue, presence: true
  validates :frequency, presence: true
  validates :start_date, presence: true, date: {
    after: Proc.new { Date.today- 6.months },
    before: Proc.new { Date.today + 1.year },
    allow_blank: true
  }


  def create_event(params)
    event.attributes           = params.slice(:name)
    event_seed.attributes      = params.slice(:url, :venue_id)
    event_generator.attributes = params.slice(:frequency, :start_date)

    if new_venue?(params[:venue])
      create_venue_form = CreateVenueForm.new
      if create_venue_form.create_venue(params[:venue])
        event_seed.venue = create_venue_form.venue
      else
        return false
      end
    end

    if valid?
      event.save!
      event_seed.save!
      event_generator.save!

      @success_message = "New event created"

      # TODO: Smelly? - it isn't clear here that @create_event_form.generate is creating event instances as well as returning dates
      dates = event_generator.generate

      date_string = dates.map(&:to_s).join(", ") # TODO: Better way of doing this - in one step?
      @success_message += ". #{dates.count} instances created: #{date_string}"
      true
    else
      false
    end
  end

  def new_venue?(venue_params)
    venue_id.nil? && not(venue_params.nil?)
  end

  def event
    @event ||= Event.new
  end

  def event_seed
    @event_seed ||= event.event_seeds.build
  end

  def event_generator
    @event_generator ||= event_seed.event_generators.build
  end

  class CreateVenueForm
    def create_venue(venue_params)
      # TODO: Need a more strong-params-esque way of handling venue params?
      venue.attributes = venue_params
      if venue.valid?
        venue.save!
        true
      else
        false
      end
    end

    def venue
      @venue ||= Venue.new
    end
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Event")
  end
end