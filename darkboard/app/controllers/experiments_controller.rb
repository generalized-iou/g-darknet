class ExperimentsController < ApplicationController
  before_action :set_experiment, only: [:show, :update, :destroy]

  # GET /experiments
  def index
    @experiments = Experiment.from_disk

    render json: @experiments
  end

  # GET /experiments/1
  def show
    render json: @experiment.get_chart
  end

  # POST /experiments
  def create
    @experiment = Experiment.new(experiment_params)

    if @experiment.save
      render json: @experiment, status: :created, location: @experiment
    else
      render json: @experiment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /experiments/1
  def update
    if @experiment.update(experiment_params)
      render json: @experiment
    else
      render json: @experiment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /experiments/1
  def destroy
    @experiment.hide
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_experiment
      @experiment = Experiment.new(Experiment.by_name(params[:id]))
    end

    # Only allow a trusted parameter "white list" through.
    def experiment_params
      params.fetch(:experiment, {})
    end
end
