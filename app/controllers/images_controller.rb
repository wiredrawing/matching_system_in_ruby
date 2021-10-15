class ImagesController < ApplicationController
  include Api::ImagesHelper
  before_action :set_image, only: %i[ show edit update destroy ]

  # GET /images or /images.json
  def index
    # ログイン中ユーザーがアップロードしたファイル一覧を取得する
    @images = Image.where({
      :member_id => @current_user.id,
    })
  end

  #######################################################
  # 指定したmember.idの画像を表示する
  # GET /images/{uuid}
  #######################################################
  def show
    file_path = @image.fetch_file_path
    p("file_path ===>", file_path)
    # 画像出力
    render({
      :file => file_path,
      :content_type => "image/jpeg",
    })
  end

  # GET /images/new
  def new
    @image = Image.new
  end

  # GET /images/1/edit
  def edit
  end

  # POST /images or /images.json
  def create
    @image = Image.new(image_params)

    respond_to do |format|
      if @image.save
        format.html { redirect_to @image, notice: "Image was successfully created." }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /images/1 or /images/1.json
  def update
    respond_to do |format|
      if @image.update(image_params)
        format.html { redirect_to @image, notice: "Image was successfully updated." }
        format.json { render :show, status: :ok, location: @image }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1 or /images/1.json
  def destroy
    @image.destroy
    respond_to do |format|
      format.html { redirect_to images_url, notice: "Image was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_image
    @image = Image.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def image_params
    params.fetch(:image, {})
  end

  helper_method :get_selected_image_url
end
