# README

## Introduction
As stated in the email, the preferred solution is to be developed on **Ruby On Rails**

- Ruby: ver 3.3.5

- Rails: ver 7.2.1

Resulting application structure comes with standard RoR boilerplate codes.

Tests are covered with **RSpec**

## Running the program
You could run the application in two ways:

### 1. Docker
The project had been deployed onto a Docker image with a cross target platforms that should be compatible with most deployments of Linux, MacOS and Windows WSL machines.

These images could be downloaded and executed directly into a Docker container in your local machine. 

Assuming that the application is running on port 3000 in the host and image:
```
docker pull szulkarnain/coding_assignment-web:latest
docker run -d -p 3000:3000 szulkarnain/coding_assignment-web:latest
```

You would be able to confirm that the server is running by checking the logs against the Container ID that was generated after the last command:

eg: ``` docker logs f3ee5b6c6efd2ba2cc0b54221853111e9b18fca4852889c39765fd3400386sda ```

If there are no errors, you would be able to access the application in the browser (assuming that it had been mapped to port 3000 as above):

eg: ``` http://localhost:3000 ```

### Troubleshooting:

There might be instances where your browser forces the protocol from HTTP to HTTPS due to HSTS (HTTP Strict Transport Security) policies. Since this assignment does not include SSL certificates, it cannot be accessed over HTTPS.

To get around this: 
- Switch to another browser that does not enforce the HSTS policy
- Run via incognito mode
- Disable the HSTS policy in the browser
- Clone the repo instead as mentioned below


### 2. Cloning the repo and running it in a local Rails server.
- Clone the repository into your local folder in a machine that has Rails installed
  - ```git clone https://github.com/zulkarnainshariff/RTCodingAssignment.git```

- Run ```rails server``` in the application folder to start the http server

- Access the application through the browser with the IP Address and port displayed

### Note:
If there are issues with running ```bundle install```, depending on the platform that Ruby is running in, there might be additional dependencies needed to be installed as stated below.

### Command line/distribution tools:

**Windows**: It may be necessary to install the yaml parser **psych** and it's required distribution platform **MSYS2** from https://www.msys2.org/ 

**MacOS**: Xcode command line tools is required. Install using __xcode-select install__ or by installing in the UI through

- __Settings > General > Software Update__

## Application details
As the application was created using the Rails framework, a boilerplate had been created within the application by Rails.

These files would be considered relevant for this assignment:
### Route
- [config/routes.rb](https://github.com/zulkarnainshariff/RTCodingAssignment/blob/main/config/routes.rb)
  - defines the root controller **csv_processor** and root path routing to **index**

### Controller
- [app/controllers/csv_processor_controller.rb](https://github.com/zulkarnainshariff/RTCodingAssignment/blob/main/app/controllers/csv_processor_controller.rb)
  - Source _.csv_ files are loaded and processed within loops where the hash results are appended into an array instance variable _@matches_
  - Outer loop iterates over the list of Jobseekers, and the inner loop will match the skills required for the job to the skills possessed by the Jobseekers
  - A value is calculated on the number of matches, and a percentage of the skills possessed to the skills required is derived from it

### View
- [app/views/csv_processor/index.html.erb](https://github.com/zulkarnainshariff/RTCodingAssignment/blob/main/app/views/csv_processor/index.html.erb)
  -  Displays the results looped from _@matches_ in a html table 

## Test coverage
Two RSpec tests were covered, each for the Controller and View

### Controller
- [spec/controllers/csv_processor_controller_spec.rb](https://github.com/zulkarnainshariff/RTCodingAssignment/blob/main/spec/controllers/csv_processor_controller_spec.rb)
  - Two temporary files were loaded, mocking the source files with mock data loaded in the same format
  - Upon accessing the root path, the instance variable _@matches_ is expected to be loaded up with two records that matched according to the mock data

### View
- [spec/views/csv_processor/index.html.erb_spec.rb](https://github.com/zulkarnainshariff/RTCodingAssignment/blob/main/spec/views/csv_processor/index.html.erb_spec.rb)
  - This test checks for the existence of the column values
  - While this formatting in the <td> elements are not part of the requirements, testing this ensures that the values are present based on the result loaded into _@matches_

## Efficiency
A script to benchmark routines were created to load 5,000,000 records to check on the efficiency
- [script/benchmark.rb](https://github.com/zulkarnainshariff/RTCodingAssignment/blob/main/script/benchmark.rb)


To run the script, execute this command in the terminal program in the root folder:

``` rails runner script/benchmark.rb ```

### Record loading:

Two record loading functions were created for testing. 
- Loading Function 1: Loading entire file and parse them as a map()
  - While this seems to be memory intensive, it loads the records at a much faster clock time
- Loading Function 2: Loading as a stream of record
  - This loads line by line using a foreach() function
  
In the benchmark tests, Loading Function 1 clocks the minimum time and is implemented in the program

### Data Processing
Two processing functions were created for testing
- Processing Function 1: Preprocess the records by parsing the skills in the individual Jobseeker and Job records. Records were then matched by testing for existence of Jobseeker's skills in the required skills of the Jobs record
  
  **Time Complexity**: O(n * m * k)
  
  n: number of jobseekers.  
  m: number of jobs.  
  k: average number of skills per jobseeker and job.
  
- Processing Function 2: Skills for records for every Jobseekers and Jobs are parsed individually
  
  **Time Complexity**: O(n * m * min(k, l))
  
    n: number of jobseekers.  
    m: number of jobs.  
    k: :average number of skills per jobseeker.  
    l: average number of skills required for each job.  
    min(k, l): intersection between skills available and skills required

In the benchmark tests, Processing Function 1 was recorded to outperform Processing Function 2 and is implemented in the program

Both unselected routines (Loading Function 2/Processing Function 2) are available in the [script/benchmark.rb](https://github.com/zulkarnainshariff/RTCodingAssignment/blob/main/script/benchmark.rb) file

```
Loaded 5000000 records
Time taken for load/map function: 142.38974179979414 seconds
Time taken for stream function: 309.28988200007007 seconds
Time taken for job_matching preprocessed function: 17.412550599779934 seconds
Time taken for job_matching loop function: 773.1980713999365 seconds
```
