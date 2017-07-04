class ArticlesController < ApplicationController

  before_action :set_article, only: [:show]

  def index
    if params[:category_id]
      @category = Category.find(params[:category_id])
      @published_articles = @category.articles.includes(:author, :categories).published.order(:published_at).reverse_order
    elsif params[:author_id]
      @author = Author.find(params[:author_id])
      @published_articles = @author.articles.includes(:author, :categories).published.reverse_order
    else
      @published_articles = Article.includes(:author, :categories).published.reverse_order
    end
    @published_articles = @published_articles.paginate(:page => params[:page], :per_page => 10)

  end


  def show

  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

end
