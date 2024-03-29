# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show]

  # GET /users/1
  def show
    render json: @user
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = if params[:id] == current_user_sub
              User.find_by_identity(params[:id])
            else
              User.find_by_key(params[:id])
            end
  end
end
