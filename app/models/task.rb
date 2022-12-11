# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :task_owner, foreign_key: "task_owner_id", class_name: "User"

  MAX_TITLE_LENGTH = 125
  validates :title, presence: true, length: { maximum: 125 }
  validates :slug, uniqueness: true
  validate :slug_not_changed

  before_create :set_slug

  belongs_to :assigned_user, foreign_key: "assigned_user_id", class_name: "User"

  private

    # def set_slug
    #   itr = 1
    #   loop do
    #     title_slug = title.parameterize
    #     slug_candidate = itr > 1 ? "#{title_slug}-#{itr}" : title_slug
    #     break self.slug = slug_candidate unless Task.exists?(slug: slug_candidate)

    #     itr += 1
    #   end
    # end

    # One solution here is to use the LIKE operator from SQLite to query all tasks with a matching slug.
    # Once we have a list of all such tasks, we can append an integer value greater than the count of such tasks to
    # parameterized task title. This will produce a unique slug.

    # def set_slug
    #   title_slug = title.parameterize
    #   latest_task_slug = Task.where(
    #     "slug LIKE ? or slug LIKE ?",
    #     "#{title_slug}",
    #     "#{title_slug}-%"
    #   ).order("LENGTH(slug) DESC", slug: :desc).first&.slug
    #   slug_count = 0
    #   if latest_task_slug.present?
    #     slug_count = latest_task_slug.split("-").last.to_i
    #     only_one_slug_exists = slug_count == 0
    #     slug_count = 1 if only_one_slug_exists
    #   end
    #   slug_candidate = slug_count.positive? ? "#{title_slug}-#{slug_count + 1}" : title_slug
    #   self.slug = slug_candidate
    # end

    def set_slug
      title_slug = title.parameterize
      regex_pattern = "slug #{Constants::DB_REGEX_OPERATOR} ?"
      latest_task_slug = Task.where(
        regex_pattern,
        "#{title_slug}$|#{title_slug}-[0-9]+$"
      ).order("LENGTH(slug) DESC", slug: :desc).first&.slug
      slug_count = 0
      if latest_task_slug.present?
        slug_count = latest_task_slug.split("-").last.to_i
        only_one_slug_exists = slug_count == 0
        slug_count = 1 if only_one_slug_exists
      end
      slug_candidate = slug_count.positive? ? "#{title_slug}-#{slug_count + 1}" : title_slug
      self.slug = slug_candidate
    end

    def slug_not_changed
      if slug_changed? && self.persisted?
        errors.add(:slug, "is immutable!")
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
