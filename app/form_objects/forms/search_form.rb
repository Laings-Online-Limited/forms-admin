class Forms::SearchForm < BaseForm
  attr_accessor :organisation_id

  def organisation
    Organisation.find_by(id: organisation_id)
  end
end
