require 'rails_helper'
require 'csv'

RSpec.describe CsvProcessorController, type: :controller do
  let(:jobseekers_csv) { Tempfile.new(['jobseekers', '.csv']) }
  let(:jobs_csv) { Tempfile.new(['jobs', '.csv']) }

  before do
    CSV.open(jobseekers_csv.path, 'w') do |csv|
      csv << ['id', 'name', 'skills']
      csv << ['1', 'Alice', 'Ruby, Rails']
      csv << ['2', 'Bob', 'JavaScript, React']
    end

    CSV.open(jobs_csv.path, 'w') do |csv|
      csv << ['id', 'title', 'required_skills']
      csv << ['1', 'Rails Developer', 'Ruby, Rails']
      csv << ['2', 'Front-end Developer', 'JavaScript, React']
    end
  end

  allow(controller)
    .to receive(:load_csv)
    .with(Rails.root.join('lib', 'csv', 'jobseekers.csv'))
    .and_return(CSV.read(jobseekers_csv.path, headers: true)
    .map(&:to_h))

  allow(controller)
    .to receive(:load_csv)
    .with(Rails.root.join('lib', 'csv', 'jobs.csv'))
    .and_return(CSV.read(jobs_csv.path, headers: true)
    .map(&:to_h))

  after do
    jobseekers_csv.close
    jobseekers_csv.unlink

    jobs_csv.close
    jobs_csv.unlink
  end

  describe 'GET #index' do
    it 'loads jobseekers and jobs and assigns @matches' do
      get :index
      expect(assigns(:matches)).to_not be_nil
      expect(assigns(:matches)).to be_an(Array)

      # In the test data above, Alice should match "Rails Developer", Bob should match "Front-end Developer"
      expect(assigns(:matches).size).to eq(2) 
    end
  end

  describe '#job_matching' do
    it 'returns correct matches' do
      jobseekers = [
        { 'id' => '1', 'name' => 'Alice', 'skills' => 'Ruby, Rails' },
        { 'id' => '2', 'name' => 'Bob', 'skills' => 'JavaScript, React' }
      ]
      jobs = [
        { 'id' => '1', 'title' => 'Rails Developer', 'required_skills' => 'Ruby, Rails' },
        { 'id' => '2', 'title' => 'Front-end Developer', 'required_skills' => 'JavaScript, React' }
      ]

      expected_matches = [
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
      ]

      expect(controller.send(:job_matching, jobseekers, jobs)).to eq(expected_matches)
    end
  end

  describe '#load_csv' do
    it 'loads and parses CSV files correctly' do
      csv_data = controller.send(:load_csv, jobseekers_csv_path)
      expect(csv_data).to be_an(Array)
      expect(csv_data.first).to eq({
        'id' => '1',
        'name' => 'Alice',
        'skills' => 'Ruby, Rails'
      })
    end
  end
end
