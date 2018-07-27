class Url < ActiveRecord::Base
  validates :longUrl, :url, presence: true
  validates_format_of :longUrl,
    with: /\A(https?|ftp):\/\/[^\s\/$.?#].[^\s]*\z/
end
