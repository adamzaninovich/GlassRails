class ExampleController < ApplicationController
  before_filter :authenticate_user!

  def index
    client = current_user.get_client
    oauth2 = client.discovered_api "oauth2", "v2"
    result = client.execute api_method: oauth2.userinfo.get
    @name = result.data.name
  end

  def add_card
    client = current_user.get_client
    mirror = client.discovered_api('mirror', 'v1')
    timeline_item = mirror.timeline.insert.request_schema.new({ 'text' => "Hello World!" })
    result = client.execute api_method: mirror.timeline.insert, body_object: timeline_item

    if result.status == 200
      @message = "Inserted new card with ID #{result.data.id}"
    else
      @message = "An error occurred: #{result.data['error']['message']}"
    end
  end

  def get_location
    client = current_user.get_client
    mirror = client.discovered_api('mirror', 'v1')
    result = client.execute api_method: mirror.locations.get, parameters: { 'id' => 'latest' }

    if result.status == 200
      location = result.data
      @message = "Location recorded on: #{location.timestamp}<br />Lat: #{location.latitude}<br />Long: #{location.longitude}<br />Accuracy: #{location.accuracy} meters"
    else
      @message = "An error occurred: #{result.data['error']['message']}"
    end
  end
end
