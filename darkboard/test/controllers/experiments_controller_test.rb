require 'test_helper'

class ExperimentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @experiment = experiments(:one)
  end

  test "should get index" do
    get experiments_url, as: :json
    assert_response :success
  end

  test "should create experiment" do
    assert_difference('Experiment.count') do
      post experiments_url, params: { experiment: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show experiment" do
    get experiment_url(@experiment), as: :json
    assert_response :success
  end

  test "should update experiment" do
    patch experiment_url(@experiment), params: { experiment: {  } }, as: :json
    assert_response 200
  end

  test "should destroy experiment" do
    assert_difference('Experiment.count', -1) do
      delete experiment_url(@experiment), as: :json
    end

    assert_response 204
  end
end
