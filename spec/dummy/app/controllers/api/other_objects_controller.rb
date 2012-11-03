class Api::OtherObjectsController < ApplicationController

  # Api::OtherObject

  before_filter do
    nested_in_resources = params.select{ |param| /_id$/ =~ param }
    params[:other_object].merge!(nested_in_resources)
    @resource = Api::OtherObject.where(nested_in_resources) if nested_in_resources.present?
  end

  def index
    render json: @other_objects = @resource.all
  end

  def create
    render json: if (@other_object = Api::OtherObject.create(params[:other_object]))
      @other_object
    else
      flash.now "Something bad Happened"
    end
  end

  def show
    render json: @other_object = Api::OtherObject.find(params[:id])
  end

  def update
    @other_object = Api::OtherObject.find(params[:id])
    render json: if @other_object.update_attributes(params[:other_object])
      @other_object
    else
      "Something bad Happened"
    end
  end

  def destroy
    @other_object = Api::OtherObject.find(params[:id])
    render json: if @other_object.delete
      { success: true }
    else
      "Something bad Happened"
    end
  end

end
