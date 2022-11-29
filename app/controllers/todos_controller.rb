# frozen_string_literal: true

class TodosController < ApplicationController
  before_action :set_todo, only: %i[show update destroy]
  before_action :configure_aserto, only: %i[update destroy]

  # authorize
  aserto_authorize_resource

  # GET /todos
  def index
    @todos = Todo.all

    render json: @todos
  end

  # GET /todos/1
  def show
    render json: @todo
  end

  # POST /todos
  def create
    @todo = Todo.new(todo_params.merge!(owner_id: current_owner))

    if @todo.save
      render json: @todo, status: :ok, location: @todo
    else
      render json: @todo.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /todos/1
  def update
    if @todo.update(todo_params)
      render json: @todo
    else
      render json: @todo.errors, status: :unprocessable_entity
    end
  end

  # DELETE /todos/1
  def destroy
    @todo.destroy
    render json: { success: true, message: "Todo deleted" }
  end

  private

  def configure_aserto
    Aserto.with_resource_mapper do |_request|
      { resource:  { OwnerID: current_owner }.transform_keys!(&:to_s) }
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_todo
    @todo = Todo.find(todo_params[:id])
  end

  # Only allow a list of trusted parameters through.
  def todo_params
    normalize_params.permit(:id, :title, :completed, :owner_id).to_h.transform_keys do |key|
      key.to_s.tableize.singularize.to_sym
    end
  end

  def normalize_params
    params.delete(:todo)
    ActionController::Parameters.new(
      params.permit(:ID, :Title, :Completed, :OwnerID, :ownerID, :id).to_h.transform_keys do |key|
        key.to_s.tableize.singularize.to_sym
      end
    )
  end
end
