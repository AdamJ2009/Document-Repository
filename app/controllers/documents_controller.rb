class DocumentsController < ApplicationController
  before_action :set_document, only: [ :show, :edit, :update, :destroy ]
  before_action :resume_session, only: %i[ index show ]
  before_action :authorize_document_access!, only: [ :show ]
  allow_unauthenticated_access only: %i[ index show ]

  def index
    @documents = Document.for_user(Current.user)
  end

  def show
  end

  def new
    @document = Document.new
  end

  def create
    @document = Document.new(document_params)
    if @document.save
      redirect_to @document, notice: "Document created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @document.update(document_params)
      redirect_to @document, notice: "Document updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @document.destroy
    redirect_to documents_path, notice: "Document deleted."
  end

  def archived
    @archived_documents = Archive.order(created_at: :desc)
  end

  # PATCH /documents/:id/restore
  def restore
    archive_record = Archive.find(params[:id])
    archive_record.restore!
    redirect_to archived_documents_path, notice: "Document restored to active library."
  end

  private

  def set_document
    @document = Document.find(params[:id])
  end

  def authorize_document_access!
    return if Current.user&.admin?

    # Use the prefixed enum predicate methods (access_admin_only? / access_logged_in?)
    if @document.access_admin_only? || (@document.access_logged_in? && Current.user.nil?)
      redirect_to documents_path, alert: "You are not authorized to view this document."
    end
  end

  def document_params
    permitted = params.require(:document).permit(:title, :file, :accessibility_level, :importance_flag, :folder_id, :new_folder_name)
    
    unless Current.user&.admin?
      permitted[:accessibility_level] = "public_access"
    end

    permitted
  end
end
