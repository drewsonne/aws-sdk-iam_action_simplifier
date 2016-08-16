require 'rspec'
require 'aws/sdk/iam_action_simplifier/tree'


describe 'set children' do

  it 'should set children' do
    tree = Tree.new
    tree.add_action('ec2:DescribeVolumeStatus', :action_path => TRUE)
    tree.child('ec2').child('Describe').child('Volume').children.first.name.should == 'Status'

    tree.add_actions(%w(iam:ListUsers iam:ListGroups ec2:DescribeInstances), :action_path => FALSE)
    tree.child('iam').child('List').children.first.name == 'Users'
  end

  it 'should count cardinality' do
    tree = Tree.new
    tree.add_action('ec2:DescribeVolumeStatus', :action_path => TRUE)
    tree.add_actions(%w(iam:ListUsers iam:ListGroups ec2:DescribeInstances), :action_path => FALSE)
    tree.child('ec2').child('Describe').child('Volume').child('Status').cardinality == 0
    tree.child('ec2').cardinality != 0
  end

  it 'should count cardinality for 2 actions' do
    tree = Tree.new
    tree.add_actions(%w(ec2:DescribeVolumeStatus ec2:DescribeInstances), :action_path => TRUE)
    tree.add_actions(%w(iam:ListUsers iam:ListGroups ec2:DescribeInstances ec2:CreateInstance), :action_path => FALSE)
    tree.child('ec2').child('Describe').cardinality == 0
    tree.child('ec2').cardinality != 0
  end

  it 'supports select' do
    tree = Tree.new
    tree.add_actions(%w(iam:ListUsers iam:ListGroups), :action_path => TRUE)
    nodes = tree.select {|node| node.name == 'Users'}
    nodes.first.name.should == 'Users'
    nodes.length.should == 1
  end

  it 'should accept .each messages' do
    tree = Tree.new
    tree.add_actions(%w(iam:ListUsers iam:ListGroups), :action_path => TRUE)

    node_names = []
    tree.each do |node|
      node_names << node.name unless node.name.nil?
    end
    node_names.sort!

    node_names.should == %w(Groups List Users iam)
  end

  it 'should return nodes by rank' do
    # Build a tree like
    #
    # +- tree
    # |
    # +-+ node1
    # | |
    # | +- node2
    # |
    # +- node3
    # |
    # +-+ node4
    #   |
    #   +- node5
    #   |
    #   +- node6
    #
    # and orders nodes like:
    #
    #    node4, node5, node6, node3, node1, node2

    node4 = Node.new('node4')
    node5 = Node.new('node5')
    node6 = Node.new('node6')
    node4.add_child('node5', node5)
    node4.add_child('node6', node6)

    node1 = Node.new('node1')
    node2 = Node.new('node2')
    node1.add_child('node2', node2)

    node3 = Node.new('node3')

    tree = Tree.new
    tree.add_child('node4', node4)
    tree.add_child('node3', node3)
    tree.add_child('node1', node1)

    node_by_rank = []
    tree.walk do |_, node|
      node_by_rank << node
    end

    node_by_rank[0].to_s.should == tree.to_s
    node_by_rank[1].to_s.should == node4.to_s
    node_by_rank[2].to_s.should == node5.to_s
    node_by_rank[3].to_s.should == node6.to_s
    node_by_rank[4].to_s.should == node3.to_s
    node_by_rank[5].to_s.should == node1.to_s
    node_by_rank[6].to_s.should == node2.to_s

  end

  it 'should skip descendents when walking' do
    # Build a tree like
    #
    # +- tree
    # |
    # +-+ node1
    # | |
    # | +- node2
    # |
    # +- node3
    # |
    # +-+ node4
    #   |
    #   +- node5
    #   |
    #   +- node6
    #
    # and orders nodes like:
    #
    #    node4, node3, node1, node2

    node4 = Node.new('node4')
    node5 = Node.new('node5')
    node6 = Node.new('node6')
    node4.add_child('node5', node5)
    node4.add_child('node6', node6)

    node1 = Node.new('node1')
    node2 = Node.new('node2')
    node1.add_child('node2', node2)

    node3 = Node.new('node3')

    tree = Tree.new
    tree.add_child('node4', node4)
    tree.add_child('node3', node3)
    tree.add_child('node1', node1)

    node_by_rank = []
    tree.walk do |walker, node|
      if node.name == 'node4'
        walker.skip_descendents_of(node)
      end
      node_by_rank << node
    end

    node_by_rank[0].to_s.should == tree.to_s
    node_by_rank[1].to_s.should == node4.to_s
    node_by_rank[2].to_s.should == node3.to_s
    node_by_rank[3].to_s.should == node1.to_s
    node_by_rank[4].to_s.should == node2.to_s
  end


end