class ExercisesController < ApplicationController
  
  def skin
    respond_to do |format|
      format.html { render :partial => 'exercises/exercises_skin' }
    end
  end

end
