# See lib/jumpstart/app/models/meta_tags.rb for more configuration details
ActiveSupport::Reloader.to_prepare do
  MetaTags.default_image = "opengraph.png"
  # MetaTags.default_title = "Default page title"
  # MetaTags.default_description = "Default page description"
end
