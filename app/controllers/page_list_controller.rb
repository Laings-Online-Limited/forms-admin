class PageListController < ApplicationController
  include CheckFormOrganisation

  def edit
    @form = Form.find(params[:form_id])
    @pages = @form.pages
    @mark_complete_form = Forms::MarkCompleteForm.new(form: @form).assign_form_values
    @mark_complete_options = mark_complete_options
  end

  def update
    @form = Form.find(params[:form_id])
    @pages = @form.pages
    @mark_complete_form = Forms::MarkCompleteForm.new(mark_complete_form_params)
    @mark_complete_options = mark_complete_options

    if @mark_complete_form.valid?
      @form.question_section_completed = @mark_complete_form.mark_complete
      if @form.save
        redirect_to form_path(@form)
      else
        raise StandardError, "Save unsuccessful"
      end
    else
      render :edit, status: :unprocessable_entity
    end
  rescue StandardError => e
    flash[:message] = e
    render :edit, status: :unprocessable_entity
  end

private

  def mark_complete_options
    [OpenStruct.new(value: "true"), OpenStruct.new(value: "false")]
  end

  def mark_complete_form_params
    params.require(:forms_mark_complete_form).permit(:mark_complete)
  end
end