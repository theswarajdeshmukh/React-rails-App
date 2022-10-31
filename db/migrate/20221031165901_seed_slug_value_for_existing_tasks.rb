# frozen_string_literal: true

class SeedSlugValueForExistingTasks < ActiveRecord::Migration[6.1]
  def up
    Task.find_each do |task|
      task.send(:set_slug)
      task.save(validate: false)
    end
  end

  def down
    Task.find_each do |task|
      task.update(slug: nil)
      task.save(validate: false)
    end
  end
end

# We have done so because the changes in up are the forward changes we want to make in our database when we apply the migration,
# whereas the changes in down are the changes we want to take place when we revert or rollback the migration.

# This ensures that upon rollback our database will go back to the state it was previously in before we applied the migration.

# In both the methods, we are querying a list of tasks from the database and iterating over them to call the set_slug method on each task to set a unique slug.
