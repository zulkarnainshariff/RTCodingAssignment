require 'csv'
require 'benchmark'
require 'tempfile'
require_relative '../app/controllers/csv_processor_controller'

# preprocessing
def generate_large_csv(row_count)
  temp_file = Tempfile.new([ 'large_file', '.csv' ])

  CSV.open(temp_file.path, 'w') do |csv|
    csv << [ 'id', 'name', 'skills' ] # Headers

    row_count.times do |i|
      csv << [ i + 1, "User#{i + 1}", "Skill#{i % 100}, Skill#{(i + 1) % 100}" ]
    end
  end

  puts "Loaded #{row_count} records"
  temp_file
end

large_csv_file = generate_large_csv(5_000_000)

# benchmark test functions
def job_matching_loop(jobseeker, jobs)
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

# - data loading
time_taken_map_loading = Benchmark.realtime do
    @jobseekers = CsvProcessorController.new.send(:load_csv, large_csv_file.path)
end

time_taken_foreach_loading = Benchmark.realtime do
    CSV.foreach(large_csv_file.path, headers: true).map(&:to_h)     
end

# - data processing
time_taken_jobmatching_preprocess = Benchmark.realtime do
    jobs = CsvProcessorController.new.send(:load_csv, Rails.root.join('lib', 'csv', 'jobs.csv'))
    CsvProcessorController.new.send(:job_matching, @jobseekers, jobs)
end

time_taken_jobmatching_loop = Benchmark.realtime do
    jobs = CsvProcessorController.new.send(:load_csv, Rails.root.join('lib', 'csv', 'jobs.csv'))
    job_matching_loop( @jobseekers, jobs)
end


# results
puts "Time taken for load/map function: #{time_taken_map_loading} seconds"
puts "Time taken for stream function: #{time_taken_foreach_loading} seconds"

puts "Time taken for job_matching preprocessed function: #{time_taken_jobmatching_preprocess} seconds"
puts "Time taken for job_matching loop function: #{time_taken_jobmatching_loop} seconds"

# cleanup
large_csv_file.close
large_csv_file.unlink
