require 'rails_helper'

RSpec.feature "Organizations", type: :feature do
  scenario 'view organizations' do
    org = Organization.create! name: 'Artsy'
    visit '/'
    expect(page).to have_content('Artsy')
  end
end
