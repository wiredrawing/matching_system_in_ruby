class DeclinesController < ApplicationController
  before_action :set_decline, only: %i[ show edit update destroy ]

  # GET /declines or /declines.json
  def index
    @declines = Decline.all
  end

  # GET /declines/1 or /declines/1.json
  def show
  end

  # GET /declines/new
  def new
    @decline = Decline.new
  end

  # GET /declines/1/edit
  def edit
  end

  # POST /declines or /declines.json
  def create
    @decline = Decline.new(decline_params)

    respond_to do |format|
      if @decline.save
        format.html { redirect_to @decline, notice: "Decline was successfully created." }
        format.json { render :show, status: :created, location: @decline }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @decline.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /declines/1 or /declines/1.json
  def update
    respond_to do |format|
      if @decline.update(decline_params)
        format.html { redirect_to @decline, notice: "Decline was successfully updated." }
        format.json { render :show, status: :ok, location: @decline }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @decline.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /declines/1 or /declines/1.json
  def destroy
    @decline.destroy
    respond_to do |format|
      format.html { redirect_to declines_url, notice: "Decline was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_decline
      @decline = Decline.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def decline_params
      params.fetch(:decline, {})
    end
end
