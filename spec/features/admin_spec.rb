# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Administration', type: :feature do
  scenario 'sets up org and project' do
    visit '/admin'
    expect(page).to have_content('Horizon')

    click_link 'Organizations'
    expect(page).to have_content('There are no Organizations')

    click_link 'New Organization'
    fill_in 'Name', with: 'Etsy'
    click_button 'Create Organization'
    expect(page).to have_content('Etsy')

    click_link 'Projects'
    expect(page).to have_content('There are no Projects')

    click_link 'New Project'
    select 'Etsy', from: 'Organization'
    fill_in 'Name', with: 'Shipping'
    click_button 'Create Project'
    expect(page).to have_content('Shipping')
  end

  scenario 'enforce basic auth on admin areas', type: :feature do
    allow(Horizon).to receive(:config).and_return(
      basic_auth_user: 'admin',
      basic_auth_pass: 'secret'
    )

    visit '/admin'
    expect(page.status_code).to eq(401)

    page.driver.header('Authorization', ActionController::HttpAuthentication::Basic.encode_credentials('admin', 'pass'))
    visit '/admin'
    expect(page.status_code).to eq(401)

    page.driver.header(
      'Authorization',
      ActionController::HttpAuthentication::Basic.encode_credentials('admin', 'secret')
    )
    visit '/admin'
    expect(page.status_code).to eq(200)
  end
end
