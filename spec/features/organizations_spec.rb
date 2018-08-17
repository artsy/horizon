require 'rails_helper'

RSpec.feature "Organizations", type: :feature do
  scenario 'view organizations' do
    org = Organization.create! name: 'Artsy'
    project = org.projects.create!(name: 'shipping')
    other_org = Organization.create! name: 'Etsy'
    other_project = other_org.projects.create!(name: 'foo_php')
    visit '/'
    expect(page).to have_content('Artsy')
    click_link 'Artsy'
    expect(page).to have_content('shipping')
    expect(page).not_to have_content('foo_php')
  end
end
