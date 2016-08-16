require 'rspec'
require 'aws/sdk/iam_action_simplifier'

describe 'Simplify' do

  it 'should return unique products' do
    actions = %w(iam:ListUsers iam:ListGroups ec2:DescribeInstances)
    action_simplifier = ::Aws::Sdk::IamActionSimplifier::Actions.new([])
    products = action_simplifier._get_product_prefixes(actions)
    products.should == %w(ec2 iam)
  end

  it 'should error on missing product' do
    actions = %w(ListUsers iam:ListGroups ec2:DescribeInstances)
    action_simplifier = ::Aws::Sdk::IamActionSimplifier::Actions.new([])
    expect do
      action_simplifier._get_product_prefixes(actions)
    end.to raise_error(ArgumentError)
  end

  it 'should return iam:*Instance' do
    action_strings = %w(iam:BundleInstance iam:ConfirmProductInstance iam:ImportInstance)
    action_simplifier = Aws::Sdk::IamActionSimplifier::Actions.new(action_strings)
    simplified = action_simplifier.simplify
    simplified.should == %w(iam:*Instance)
  end

  it 'should return an add wildcard' do
    action_strings = %w(iam:AddClientIDToOpenIDConnectProvider iam:AddRoleToInstanceProfile iam:AddUserToGroup)
    action_simplifier = Aws::Sdk::IamActionSimplifier::Actions.new(action_strings)
    simplified = action_simplifier.simplify
    simplified.should == %w(iam:Add*)
  end

  it 'should return two wildcards' do
    action_strings = %w(iam:AddClientIDToOpenIDConnectProvider iam:AddRoleToInstanceProfile iam:AddUserToGroup ec2:*)
    action_simplifier = Aws::Sdk::IamActionSimplifier::Actions.new(action_strings)
    simplified = action_simplifier.simplify
    simplified.should == %w(ec2:* iam:Add*)
  end

  it 'should return full arguments' do
    action_strings = %w(iam:AddClientIDToOpenIDConnectProvider iam:AddRoleToInstanceProfile iam:AddUserToGroup iam:AttachGroupPolicy)
    action_simplifier = Aws::Sdk::IamActionSimplifier::Actions.new(action_strings)
    simplified = action_simplifier.simplify
    simplified.should == %w(iam:Add* iam:AttachGroupPolicy)
  end

end