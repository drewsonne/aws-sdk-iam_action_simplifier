require 'rspec'
require 'aws/sdk/iam_action_simplifier/load_static'

describe 'Get Resource Path' do

  it 'should return resource folder path' do
    path = LoadStatic.path_to_resources
    path.should == File.expand_path('../../resources', __FILE__)
  end

  it 'should return resource path' do
    path = LoadStatic.resource_path('my/resource.file')
    path.should == File.expand_path('../../resources/my/resource.file', __FILE__)
  end
end