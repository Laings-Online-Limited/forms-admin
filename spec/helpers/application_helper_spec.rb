require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#link_to_runner" do
    context "with no live argument" do
      it "returns url to the form-runner's preview form" do
        expect(helper.link_to_runner("example.com", 2, "garden-form-slug")).to eq "example.com/preview-form/2/garden-form-slug"
      end
    end

    context "with live set to false" do
      it "returns url to the form-runner's preview form" do
        expect(helper.link_to_runner("example.com", 2, "garden-form-slug", live: false)).to eq "example.com/preview-form/2/garden-form-slug"
      end
    end

    context "with live set to true" do
      it "returns url to the form-runner's live form" do
        expect(helper.link_to_runner("example.com", 2, "garden-form-slug", live: true)).to eq "example.com/form/2/garden-form-slug"
      end
    end
  end
end