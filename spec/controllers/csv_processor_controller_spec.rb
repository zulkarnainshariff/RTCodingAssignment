require 'rails_helper'
require 'csv'
require 'fileutils'

RSpec.describe CsvProcessorController, type: :controller do
  let(:temp_dir) { Rails.root.join('tmp', 'csv') }

  before do
    FileUtils.mkdir_p(temp_dir)

    @jobseekers_csv = Tempfile.new([ 'jobseekers', '.csv' ], temp_dir)
    @jobs_csv = Tempfile.new([ 'jobs', '.csv' ], temp_dir)

    CSV.open(@jobseekers_csv.path, 'w') do |csv|
      csv << [ 'id', 'name', 'skills' ]
      csv << [ '1', 'Alice', 'Ruby, Rails' ]
      csv << [ '2', 'Bob', 'JavaScript, React' ]
    end

    CSV.open(@jobs_csv.path, 'w') do |csv|
      csv << [ 'id', 'title', 'required_skills' ]
      csv << [ '1', 'Rails Developer', 'Ruby, Rails' ]
      csv << [ '2', 'Front-end Developer', 'JavaScript, React' ]
    end

    # Check that the method is an instance method of Pathname else it could trigger an issue of mismatched type if is called without checking for this type
    # This is in comparison to having the name concantenated as a
 string    
    allow(controller).to receive(:load_csv)
      .with(instance_of(Pathname))
      .and_wrap_original do |original_load_csv, arg| 
        # wrap the original load_csv as well to override the behaviour to load mock data instead

        path = arg.to_s
        if path.include?('jobseekers')
          CSV.read(@jobseekers_csv.path, headers: true).map(&:to_h)
        elsif path.include?('jobs')
          CSV.read(@jobs_csv.path, headers: true).map(&:to_h)
        else
          original_load_csv.call(arg)
        end
      end
  end

  after do
    @jobseekers_csv.close
    @jobseekers_csv.unlink

    @jobs_csv.close
    @jobs_csv.unlink

    FileUtils.rm_rf(temp_dir)
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
      csv_data = controller.send(:load_csv, Pathname.new(@jobseekers_csv.path))
      expect(csv_data).to be_an(Array)
      expect(csv_data.first).to eq({
        'id' => '1',
        'name' => 'Alice',
        'skills' => 'Ruby, Rails'
      })
    end
  end
end
