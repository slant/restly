class Api::SampleObjectsController < ApplicationController

  def index
    render json: @sample_objects = Api::SampleObject.all
  end

  def create
    if (@sample_object = Api::SampleObject.create(params[:sample_object]))
      redirect_to @sample_object
    else
      flash.now "Something bad Happened"
    end
  end

  def show
    render json: @sample_object = Api::SampleObject.find(params[:id])
  end

  def update
    @sample_object = Api::SampleObject.find(params[:id])
    render json: if @sample_object.update_attributes(params[:sample_object])
      redirect_to @sample_object
    else
      "Something bad Happened"
    end
  end

  def destroy
    @sample_object = Api::SampleObject.find(params[:id])
    render json: if @sample_object.delete
      redirect_to sample_objects_path
    else
      "Something bad Happened"
    end
  end

end
