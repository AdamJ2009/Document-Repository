class FoldersController < ApplicationController
  # Only run set_folder on actions that expect a specific folder ID
  before_action :set_folder, only: [:show, :edit, :update, :archive, :restore]

  def index
    @folders = Folder.active
    @folder = Folder.new
  end

  def show
    @documents = @folder.documents.for_user(Current.user)
  end

  def create
    @folder = Folder.new(folder_params)
    if @folder.save
      redirect_to folders_path, notice: "Folder created successfully."
    else
      @folders = Folder.active
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @folder.update(folder_params)
      redirect_to folders_path, notice: "Folder renamed."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # PATCH /folders/:id/archive (Performs the action)
  def archive
    @folder.archive!
    redirect_to folders_path, notice: "Folder archived."
  end

  # GET /folders/archived (Renders the archived list view)
  def archived
    @folders = Folder.archived
  end

  # PATCH /folders/:id/restore (Restores an archived folder)
  def restore
    @folder.restore!
    redirect_to archived_folders_path, notice: "Folder restored."
  end

  private

  def set_folder
    @folder = Folder.find(params[:id])
  end

  def folder_params
    params.require(:folder).permit(:name)
  end
end