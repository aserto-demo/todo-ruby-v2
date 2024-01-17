# frozen_string_literal: true

class TodosController < ApplicationController
  before_action :set_todo, only: %i[show update destroy]
  before_action :configure_aserto, only: %i[update destroy]
  before_action :configure_policy_root

  # authorize
  aserto_authorize_resource except: %i[create]

  # GET /todos
  def index
    @todos = Todo.all

    render json: @todos
  end

  # GET /todos/:id
  def show
    render json: @todo
  end

  # POST /todos
  def create
    Aserto.configure do |config|
      config.policy_root = "rebac"
    end
    check!(object_type: "resource-creator", object_id: "resource-creators", relation: "member")

    @todo = Todo.new(mutable_todo_params)

    if @todo.save
      render json: @todo, status: :ok, location: @todo
    else
      render json: @todo.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /todos/:id
  def update
    if @todo.update(update_todo_params)
      render json: @todo
    else
      render json: @todo.errors, status: :unprocessable_entity
    end
  end

  # DELETE /todos/:id
  def destroy
    @todo.destroy
    render json: { success: true, message: "Todo deleted" }
  end

  private

  def configure_policy_root
    Aserto.configure do |config|
      config.policy_root = ENV.fetch("ASERTO_POLICY_ROOT", nil)
    end
  end

  def configure_aserto
    return unless @todo

    Aserto.with_resource_mapper do |_request|
      { object_id: @todo.id.to_s }.transform_keys!(&:to_s)
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

  def update_todo_params
    normalize_params.permit(:title, :completed).to_h.transform_keys do |key|
      key.to_s.tableize.singularize.to_sym
    end
  end

  def mutable_todo_params
    user = User.find_by_identity(current_user_sub)
    update_todo_params.merge!(owner_id: user.id)
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
