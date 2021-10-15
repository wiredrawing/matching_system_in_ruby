module Api::ImagesHelper
  def get_selected_image_url(image_id)
    api_images_owner_show_url({
      :id => image_id,
    })
  end
end
