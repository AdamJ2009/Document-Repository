class ArchivesController < ApplicationController
  before_action :set_archive, only: [ :show ]
  before_action :require_admin!

  def index
    @archives = Archive.all
  end

  def show
    @archive = Archive.find(params[:id])
  end

  def new
    @archive = Archive.new
  end

  def create
    @archive = Archive.new(archive_params)

    if @archive.save
      redirect_to @archive, notice: "Document archived."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def restore
    @archive = Archive.find(params[:id])
    @archive.restore!
    redirect_to archives_path, notice: "Document restored to active library."
  end

  private

  def set_archive
    @archive = Archive.find(params[:id])
  end

  def archive_params
    params.require(:archive).permit(:title, :file)
  end
end
