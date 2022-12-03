# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :load_task!, only: %i[show update destroy]

  # Note that, we have used a bang operator with the load_task! method name because the
  # method will return an exception n case a task is not found. It is a Ruby convention
  # for method names to end with a bang operator if they raise an exception.

  def index
    tasks = Task.all.as_json(include: { assigned_user: { only: %i[name id] } })
    respond_with_json({ tasks: tasks })
  end

  def show
    respond_with_json({ task: @task, assigned_user: @task.assigned_user })
  end

  def update
    @task.update!(task_params)
    respond_with_success(t("successfully_updated"))
  end

  def create
    task = Task.new(task_params)
    task.save!
    respond_with_success(t("successfully_created"))
  end

  def destroy
    @task.destroy!
    respond_with_json
  end

  private

    def load_task!
      @task = Task.find_by!(slug: params[:slug])
    end

    def task_params
      params.require(:task).permit(:title, :assigned_user_id)
    end
end
