class Announcement < ApplicationRecord
  TYPES = %w[new fix improvement update]

  scope :draft, -> { where(published_at: nil) }
  scope :published, -> { where.not(published_at: nil) }

  has_rich_text :description

  validates :kind, :title, :description, presence: true

  attribute :published_at
  to_param :title

  def self.unread?(user)
    most_recent_announcement = published.maximum(:published_at)
    most_recent_announcement && (user.nil? || user.announcements_read_at&.before?(most_recent_announcement))
  end

  def to_meta_tags
    {
      title: title,
      description: description.to_plain_text.truncate(155, omission: "")
    }
  end
end
