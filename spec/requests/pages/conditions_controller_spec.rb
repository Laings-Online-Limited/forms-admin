require "rails_helper"

RSpec.describe Pages::ConditionsController, type: :request do
  let(:form) { build :form, id: 1 }
  let(:pages) { build_list :page, 5, :with_selections_settings, form_id: form.id }

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

  describe "#routing_page" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
      end

      get routing_page_path(form_id: form.id)
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end

    it "renders the routing page template" do
      expect(response).to render_template("pages/conditions/routing_page")
    end
  end

  describe "#set_routing_page" do
    let(:selected_page) { pages.first }

    before do
      selected_page.id = 1
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/1", req_headers, selected_page.to_json, 200
      end

      post routing_page_path(form_id: 1, params: { form: { routing_page_id: 1 } })
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end

    it "redirects the user to the new conditions page" do
      expect(response).to redirect_to new_condition_path(form.id, selected_page.id)
    end
  end

  describe "#new" do
    let(:selected_page) { pages.first }

    before do
      selected_page.id = 1
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/1", req_headers, selected_page.to_json, 200
      end

      get new_condition_path(form_id: 1, page_id: 1)
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end

    it "renders the new condition page template" do
      expect(response).to render_template("pages/conditions/new")
    end
  end
end
