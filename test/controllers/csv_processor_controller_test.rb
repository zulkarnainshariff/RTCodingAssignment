require "test_helper"

class CsvProcessorControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get csv_processor_index_url
    assert_response :success
  end
end
