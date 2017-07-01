class Admin::HeaderSectionsController < ApplicationController

  before_action :set_header_section, only: [:edit, :update, :delete, :destroy]
  before_action :content_to_markdown, only: :edit
  before_action :authenticate_admin!

  def index
    @header_sections = HeaderSection.all.paginate(:page => params[:page], :per_page => 100)
  end
  
  def new
    @header_section = HeaderSection.new
  end

  def create
    @header_section = HeaderSection.new(header_section_params)
    if @header_section.save
      redirect_to edit_admin_header_section_path(@header_section), notice: 'Header section was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @header_section.update(header_section_params)
      redirect_to edit_admin_header_section_path, notice: 'Header section was successfully updated.'
    else
      render :edit
    end

  end

  def delete

  end
  
  def destroy
    @header_section.destroy
    redirect_to admin_header_sections_path, notice: 'Header section was successfully destroyed.'
  end
  
  private

  def set_header_section
    @header_section = HeaderSection.find(params[:id])
  end

  def content_to_markdown
    @header_section.convert_content_to_markdown
  end
    
  def header_section_params
    params.require(:header_section).permit(:position, :content)
  end

end