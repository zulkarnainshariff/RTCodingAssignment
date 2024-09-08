require 'csv'

class CsvProcessorController < ApplicationController

  def index
    jobseekers = []
    jobs = []

    jobseekers = load_csv(Rails.root.join('lib', 'csv','jobseekers.csv'))
    jobs = load_csv(Rails.root.join('lib', 'csv','jobs.csv'))

    @matches = job_matching(jobseekers, jobs)
  end

  private

  def job_matching(jobseeker, jobs)
    matches = []

    jobseeker.each do |jobseeker|
      jobseeker_skills = jobseeker['skills'].split(',').map(&:strip).map(&:downcase)

      jobs.each do |job|
        required_skills = job['required_skills'].split(',').map(&:strip).map(&:downcase)

        matching_skills = jobseeker_skills & required_skills
        match_count = matching_skills.count

        if match_count > 0
          matches << { 
              jobseeker_id: jobseeker['id'], 
              jobseeker_name: jobseeker['name'], 
              job_id: job['id'], 
              job_title: job['title'], 
              matching_skill_count: match_count,
              matching_skill_percent: (match_count.to_f / required_skills.count.to_f * 100).round(2)
            }
        end
      end
    end

    matches
  end

  def load_csv(file_path)
    csv = CSV.read(file_path, headers: true)
    csv.map(&:to_h)
  end

end
