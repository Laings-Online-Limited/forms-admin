require "rails_helper"

RSpec.describe "groups/index", type: :view do
  let(:trial_groups) { create_list :group, 2 }
  let(:active_groups) { create_list :group, 2, status: :active }
  let(:current_user) { build :editor_user }

  before do
    assign(:trial_groups, trial_groups)
    assign(:active_groups, active_groups)

    assign(:current_user, current_user)

    render
  end

  it "renders a list of groups" do
    trial_groups.each do |group|
      expect(rendered).to have_link(group.name, href: group_path(group))
    end

    active_groups.each do |group|
      expect(rendered).to have_link(group.name, href: group_path(group))
    end
  end

  it "shows a create group button" do
    expect(rendered).to have_link("Create a group", href: new_group_path)
  end

  it "shows the details text for users who are not org/super admins" do
    expect(rendered).to have_content("If you need access to an existing form or group, ask someone who has access to that group to add you.")
  end

  context "when the user is an admin" do
    let(:current_user) { build :organisation_admin_user }

    it "shows the details text for admins" do
      expect(rendered).to have_content("Because you’re an organisation admin, you can access all the groups in your organisation.")
    end
  end
end
