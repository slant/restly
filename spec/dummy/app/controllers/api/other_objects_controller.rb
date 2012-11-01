class Api::OtherObjectsController < ApplicationController

  # Api::OtherObject

  before_filter do
    nested_in_resources = params.select{ |param| /_id$/ =~ param }
    @resource = Api::OtherObject.where(nested_in_resources) if nested_in_resources.present?
  end

  def index
    render json: @sample_objects = @resource.all
  end

  def create
    if (@sample_object = @resource.create(params[:sample_object]))
      redirect_to @sample_object
    else
      flash.now "Something bad Happened"
    end
  end

  def show
    render json: @sample_object = Api::OtherObject.find(params[:id])
  end

  def update
    @sample_object = Api::OtherObject.find(params[:id])
    render json: if @sample_object.update_attributes(params[:sample_object])
      redirect_to @sample_object
    else
      "Something bad Happened"
    end
  end

  def destroy
    @sample_object = Api::OtherObject.find(params[:id])
    render json: if @sample_object.delete
      redirect_to sample_objects_path
    else
      "Something bad Happened"
    end
  end

end
