require "rails_helper"

RSpec.describe Pages::ConditionsController, type: :request do
  let(:form) { build :form, :ready_for_routing, id: 1 }
  let(:pages) { form.pages }
  let(:page) { pages.first }
  let(:selected_page) { page }

  let(:submit_result) { true }

  let(:req_headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Accept" => "application/json",
    }
  end

  let(:post_headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Content-Type" => "application/json",
    }
  end

  let(:expected_to_raise_error) { false }

  describe "#routing_page" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
      end

      if expected_to_raise_error
        allow(Pundit).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
      else
        allow(Pundit).to receive(:authorize).and_return(true)
      end

      get routing_page_path(form_id: form.id)
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end

    it "renders the routing page template" do
      expect(response).to render_template("pages/conditions/routing_page")
    end

    context "when user should not be allowed to  add routes to pages" do
      let(:expected_to_raise_error) { true }

      it "Renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "Returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end
  end

  describe "#set_routing_page" do
    before do
      selected_page.id = 1
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/1", req_headers, selected_page.to_json, 200
      end

      if expected_to_raise_error
        allow(Pundit).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
      else
        allow(Pundit).to receive(:authorize).and_return(true)
      end

      post routing_page_path(form_id: 1, params: { form: { routing_page_id: 1 } })
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end

    it "redirects the user to the new conditions page" do
      expect(response).to redirect_to new_condition_path(form.id, selected_page.id)
    end

    context "when user should not be allowed to add routes to pages" do
      let(:expected_to_raise_error) { true }

      it "Renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "Returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end
  end

  describe "#new" do
    before do
      selected_page.id = 1
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/1", req_headers, selected_page.to_json, 200
      end

      if expected_to_raise_error
        allow(Pundit).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
      else
        allow(Pundit).to receive(:authorize).and_return(true)
      end

      get new_condition_path(form_id: 1, page_id: 1)
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end

    it "renders the new condition page template" do
      expect(response).to render_template("pages/conditions/new")
    end

    context "when user should not be allowed to add routes to pages" do
      let(:expected_to_raise_error) { true }

      it "Renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "Returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end
  end

  describe "#create" do
    before do
      selected_page.id = 1
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/1", req_headers, selected_page.to_json, 200
      end

      if expected_to_raise_error
        allow(Pundit).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
      else
        allow(Pundit).to receive(:authorize).and_return(true)
      end

      conditional_form = Pages::ConditionsForm.new(form:, page: selected_page, answer_value: "Yes", goto_page_id: 3)

      allow(conditional_form).to receive(:submit).and_return(submit_result)

      allow(Pages::ConditionsForm).to receive(:new).and_return(conditional_form)

      post create_condition_path(form_id: form.id, page_id: selected_page.id, params: { pages_conditions_form: { routing_page_id: 1, check_page_id: 1, goto_page_id: 3, answer_value: "Wales" } })
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end

    it "redirects to the page list" do
      expect(response).to redirect_to form_pages_path(form.id)
    end

    context "when form submit fails" do
      let(:submit_result) { false }

      it "return 422 error code" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders new page" do
        expect(response).to render_template("pages/conditions/new")
      end
    end

    context "when user should not be allowed to add routes to pages" do
      let(:expected_to_raise_error) { true }

      it "Renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "Returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end
  end

  describe "#edit" do
    let(:routing_conditions) { build :condition, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 3 }

    before do
      selected_page.routing_conditions = [routing_conditions]
      selected_page.position = 1
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/#{selected_page.id}", req_headers, selected_page.to_json, 200
        mock.get "/api/v1/forms/1/pages/#{selected_page.id}/conditions/1", req_headers, routing_conditions.to_json, 200
      end

      if expected_to_raise_error
        allow(Pundit).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
      else
        allow(Pundit).to receive(:authorize).and_return(true)
      end

      get edit_condition_path(form_id: 1, page_id: selected_page.id, condition_id: routing_conditions.id)
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end

    it "renders the new condition page template" do
      expect(response).to render_template("pages/conditions/edit")
    end

    context "when user should not be allowed to add routes to pages" do
      let(:expected_to_raise_error) { true }

      it "Renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "Returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end
  end

  describe "#update" do
    let(:routing_conditions) { build :condition, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 3 }

    before do
      selected_page.routing_conditions = [routing_conditions]
      selected_page.position = 1
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/#{selected_page.id}", req_headers, selected_page.to_json, 200
        mock.get "/api/v1/forms/1/pages/#{selected_page.id}/conditions/1", req_headers, routing_conditions.to_json, 200
      end

      if expected_to_raise_error
        allow(Pundit).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
      else
        allow(Pundit).to receive(:authorize).and_return(true)
      end

      conditional_form = Pages::ConditionsForm.new(form:, page: selected_page, record: routing_conditions, answer_value: "Yes", goto_page_id: 3)

      allow(conditional_form).to receive(:update).and_return(submit_result)

      allow(Pages::ConditionsForm).to receive(:new).and_return(conditional_form)

      put update_condition_path(form_id: form.id,
                                page_id: selected_page.id,
                                condition_id: routing_conditions.id,
                                params: { pages_conditions_form: { routing_page_id: 1, check_page_id: 1, goto_page_id: 3, answer_value: "Wales" } })
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end

    it "redirects to the page list" do
      expect(response).to redirect_to form_pages_path(form.id)
    end

    context "when form submit fails" do
      let(:submit_result) { false }

      it "return 422 error code" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders new page" do
        expect(response).to render_template("pages/conditions/edit")
      end
    end

    context "when user should not be allowed to add routes to pages" do
      let(:expected_to_raise_error) { true }

      it "Renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "Returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end
  end
end