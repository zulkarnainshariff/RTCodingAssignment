require 'rails_helper'

RSpec.describe 'csv_processor/index.html.erb', type: :view do
  before do
    assign(:matches, [
      {
        jobseeker_id: '1',
        jobseeker_name: 'Alice',
        job_id: '1',
        job_title: 'Rails Developer',
        matching_skill_count: 2,
        matching_skill_percent: 100.0
      },
      {
        jobseeker_id: '2',
        jobseeker_name: 'Bob',
        job_id: '2',
        job_title: 'Front-end Developer',
        matching_skill_count: 2,
        matching_skill_percent: 100.0
      }
    ])
  end

  it 'renders the table headers and rows correctly' do
    render
    expect(rendered).to have_selector('th', text: 'jobseeker_id')
    expect(rendered).to have_selector('th', text: 'jobseeker_name')
    expect(rendered).to have_selector('th', text: 'job_id')
    expect(rendered).to have_selector('th', text: 'job_title')
    expect(rendered).to have_selector('th', text: 'matching_skill_count')
    expect(rendered).to have_selector('th', text: 'matching_skill_percent')

    expect(rendered).to have_selector('td', text: '1')
    expect(rendered).to have_selector('td', text: 'Alice')
    expect(rendered).to have_selector('td', text: '1')
    expect(rendered).to have_selector('td', text: 'Rails Developer')
    expect(rendered).to have_selector('td', text: '2')
    expect(rendered).to have_selector('td', text: '100.0')

    expect(rendered).to have_selector('td', text: '2')
    expect(rendered).to have_selector('td', text: 'Bob')
    expect(rendered).to have_selector('td', text: '2')
    expect(rendered).to have_selector('td', text: 'Front-end Developer')
    expect(rendered).to have_selector('td', text: '2')
    expect(rendered).to have_selector('td', text: '100.0')
  end
end
