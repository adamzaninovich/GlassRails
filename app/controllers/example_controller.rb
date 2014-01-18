class ExampleController < ApplicationController
  before_filter :authenticate_user!

  def index
  end

  def show_cards
    @cards = api.timeline.list.items
  end

  def delete_cards
    api.timeline.list.items.map(&:id).each do |card_id|
      api.timeline.delete card_id
    end
    flash[:notice] = "All cards deleted"
    redirect_to example_show_cards_path, notice: "All Cards Deleted"
  end

  def add_card
    title = "Take Me To Church"
    artist = "Hozier"

    card = {
      bundle_id: "ekho",
      notification: {level:"DEFAULT"},
      menu_items: [
        {action:"CUSTOM", id:"pause", values:[{displayName:"Pause Song"}]},
        {action:"READ_ALOUD"},
        {action:"DELETE"}
      ],
      text: "The current song is #{title} by #{artist} - Powered by echo.",
      html: "<article><section><h1 class=\"text-auto-size blue\">#{title}</h1><h2 class=\"muted\">#{artist}</h2></section><footer><div>powered by <span class=\"red\">EKHO</span></div></footer></article>"
    }

    @card = api.timeline.insert card
  end

  def get_location
    location = api.locations.get "latest"
    @message = "Location recorded on: #{location.timestamp}<br />Lat: #{location.latitude}<br />Long: #{location.longitude}<br />Accuracy: #{location.accuracy} meters"
  end

  private

  def api
    @api ||= current_user.get_mirror_api_client
  end

end
