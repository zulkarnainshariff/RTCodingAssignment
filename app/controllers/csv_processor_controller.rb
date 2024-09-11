require 'csv'

class CsvProcessorController < ApplicationController

  def index
    jobseekers = load_csv(Rails.root.join('lib', 'csv','jobseekers.csv'))
    jobs = load_csv(Rails.root.join('lib', 'csv','jobs.csv'))

    @matches = job_matching(jobseekers, jobs)
  end

  private

  def job_matching(jobseekers, jobs)
    matches = []

    # Preprocess job skills for quick lookup
    jobs_with_skills = preprocess_jobs(jobs)

    jobseekers.each do |jobseeker|
      jobseeker_skills = parse_skills(jobseeker['skills'])

      # Find job matches for each jobseeker
      jobs_with_skills.each do |job|
        match = find_match(jobseeker, job, jobseeker_skills)
        matches << match if match
      end
    end

    matches
  end

  def preprocess_jobs(jobs)
    jobs.map do |job|
      job.merge(required_skills: parse_skills(job['required_skills']))
    end
  end

  # used for parsing both jobs and jobseekers skills
  def parse_skills(skills)
    skills.split(',').map(&:strip).map(&:downcase)
  end

  def find_match(jobseeker, job, jobseeker_skills)
    matching_skills = jobseeker_skills & job[:required_skills]
    match_count = matching_skills.count

    return nil if match_count.zero?

    {
      jobseeker_id: jobseeker['id'],
      jobseeker_name: jobseeker['name'],
      job_id: job['id'],
      job_title: job['title'],
      matching_skill_count: match_count,
      matching_skill_percent: (match_count.to_f / job[:required_skills].count * 100).round(2)
    }
  end

  def load_csv(file_path)
    CSV.read(file_path, headers: true).map(&:to_h)
  end
end
