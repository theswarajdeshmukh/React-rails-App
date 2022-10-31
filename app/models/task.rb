# frozen_string_literal: true

class Task < ApplicationRecord
  MAX_TITLE_LENGTH = 125
  validates :title, presence: true, length: { maximum: 125 }
  validates :slug, uniqueness: true
  validate :slug_not_changed

  before_create :set_slug

  private

    def set_slug
      itr = 1
      loop do
        title_slug = title.parameterize
        slug_candidate = itr > 1 ? "#{title_slug}-#{itr}" : title_slug
        break self.slug = slug_candidate unless Task.exists?(slug: slug_candidate)

        itr += 1
      end
    end

    def slug_not_changed
      if slug_changed? && self.persisted?
        errors.add(:slug, t("task.slug.immutable"))
      end
    end
end
# We make use of column_name_changed? attribute method provided by ActiveModel::Dirty module.
# It provides a way to track changes in our object in the same way as Active Record does. In simpler terms,
# if we need to know if a particular database column has changed in database level,
# then we can make use of these methods.

# self is a Ruby keyword that gives you access to the current object. Here, it will be the current task.

# persisted? is a Ruby method, part of ActiveRecord::Persistence, which returns true if the record is persisted, i.e. it's not a new record and it was not destroyed, and otherwise returns false.

# So, here slug_changed? && self.persisted? is ensuring that slug has changed as well as persisted.

# set_slug method is setting slug attribute as a parameterized version of the title. When doing so,
# if the same slug already exists in the database, we use an iterator and append it to the end of the slug,
# and loop until we generate an unique slug.

##  parameterize is part of ActiveSupport, which replaces special characters in a string so that it may be used as
## part of a 'pretty' URL
