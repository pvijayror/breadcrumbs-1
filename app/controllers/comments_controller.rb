class CommentsController < ApplicationController
  before_filter :authenticate!, :except => [:create]
  
  def index
    @comments = Comment.pending
  end
  
  def approve
    @comment = Comment.find(params[:id])
    @comment.approved = true
    @comment.save!
    respond_to do |format|
      format.html { redirect_to comments_path, notice: 'Comment was approved' }
      format.json { head :ok }
    end
  end
  
  # POST /comments
  # POST /comments.json
  def create
    @comment = Comment.new(params[:comment])
    @comment.approved = false
    @comment.post_id = params[:post_id]
    @post = @comment.post

    respond_to do |format|
      if verify_recaptcha(:model => @comment, :message => "Captcha is incorrect, please try again.") and @comment.save
        format.html { redirect_to @comment.post, notice: 'Comment was successfully created.' }
        format.json { render json: @comment, status: :created, location: @comment }
      else
        format.html { flash[:alert] = 'There were errors posting your comment.'; render "posts/show" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to post_path(@comment.post), notice: 'Comment was successfully deleted.' }
      format.json { head :ok }
    end
  end
end
