class Admin::ArticlesController < ApplicationController

  before_action :set_article, only: [:edit, :update, :delete, :destroy]

  def index
    @articles = Article.all.reverse
  end
  
  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)
    if @article.save
      redirect_to admin_articles_path, notice: 'Article was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @article.update(article_params)
      redirect_to admin_articles_path, notice: 'Article was successfully updated.'
    else
      render :edit
    end

  end

  def delete

  end
  
  def destroy
    @article.destroy
    redirect_to admin_articles_path, notice: 'Article was successfully destroyed.'
  end
  
  private

  def set_article
    @article = Article.find(params[:id])
  end
    
  def article_params
    params.require(:article).permit(:title, :privacy, :content, :author_id)
  end

end
