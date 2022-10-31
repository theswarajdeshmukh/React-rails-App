# frozen_string_literal: true

class MakeSlugNotNullable < ActiveRecord::Migration[6.1]
  def change
    change_column_null :tasks, :slug, false
  end
end

# change_column_null sets or removes the NOT NULL constraint on a column.

# It takes three arguments. First argument is the table name,
# second argument is the name of the column we want to apply the constraint to and the last value is a boolean value.

# Passing false in the above migration will set the database constraint.
# In simpler words, it won't allow the value in slug column to be null.
