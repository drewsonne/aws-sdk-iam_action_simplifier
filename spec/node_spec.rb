require 'rspec'
require 'aws/sdk/iam_action_simplifier/tree'

describe 'Node Behaviour' do

  it 'should report parent correctly' do
    node = Node.new
    parent = Node.new

    parent.add_child('child', node)

    parent.children.first.should == node
    node.parent.should == parent
  end

  it 'should report as a leaf' do

    node = Node.new
    node.leaf?.should == TRUE
    node.children.length.should == 0

    node.add_child('child1', Node.new)
    node.leaf?.should == FALSE
    node.children.length.should == 1

    node.add_child('child2', Node.new)
    node.leaf?.should == FALSE
    node.children.length.should == 2

  end

  it 'should report as root' do

    node = Node.new
    node.root?.should == TRUE

    node.parent = Node.new
    node.root?.should == FALSE

  end

  it 'should report rank' do

    node = Node.new
    node.rank.should == 0

    parent_node = Node.new
    node.parent = parent_node
    node.rank.should == 1

    root_node = Node.new
    parent_node.parent = root_node
    node.rank.should == 2

  end

  it 'should report root siblings action state' do

    node = Node.new
    node.all_siblings_in_action?.should == TRUE
  end

  it 'should report siblings action state as true' do
    parent_node = Node.new

    node1 = Node.new
    node1.in_action_path = TRUE
    node2 = Node.new
    node2.in_action_path = TRUE

    parent_node.add_child('child1', node1)
    parent_node.add_child('child2', node2)

    node1.all_siblings_in_action?.should == TRUE

  end

  it 'should reports siblings action state as false' do
    parent_node = Node.new

    node1 = Node.new
    node1.in_action_path = TRUE
    node2 = Node.new
    node2.in_action_path = FALSE

    parent_node.add_child('child1', node1)
    parent_node.add_child('child2', node2)

    node1.all_siblings_in_action?.should == FALSE
  end

  it 'should report all children in action as true' do
    parent_node = Node.new

    node1 = Node.new
    node1.in_action_path = TRUE
    parent_node.add_child('node1', node1)

    node2 = Node.new
    node2.in_action_path = TRUE
    parent_node.add_child('node2', node2)

    node3 = Node.new
    node3.in_action_path = TRUE
    parent_node.add_child('node3', node3)

    parent_node.all_children_in_action?.should == TRUE
  end

  it 'should report all children in action as false' do
    parent_node = Node.new

    node1 = Node.new
    node1.in_action_path = TRUE
    parent_node.add_child('node1', node1)

    node2 = Node.new
    node2.in_action_path = FALSE
    parent_node.add_child('node2', node2)

    node3 = Node.new
    node3.in_action_path = TRUE
    parent_node.add_child('node3', node3)

    parent_node.all_children_in_action?.should == FALSE
  end

  it 'should report all descendents in action as true' do
    node1 = Node.new
    node1.in_action_path = TRUE

    node2 = Node.new
    node2.in_action_path = TRUE
    node1.add_child('node2', node2)

    node3 = Node.new
    node3.in_action_path = TRUE
    node2.add_child('node3', node3)

    node4 = Node.new
    node4.in_action_path = TRUE
    node3.add_child('node4', node4)

    node1.all_descendents_in_action?.should == TRUE

  end

  it 'should report all descendents in action as false' do
    node1 = Node.new('node1')
    node1.in_action_path = TRUE

    node2 = Node.new('node2')
    node2.in_action_path = TRUE
    node1.add_child('node2', node2)

    node3 = Node.new('node3')
    node3.in_action_path = TRUE
    node2.add_child('node3', node3)

    node4 = Node.new('node4')
    node4.in_action_path = FALSE
    node3.add_child('node4', node4)

    node1.all_descendents_in_action?(TRUE).should == FALSE

  end

  it 'should show single path' do
    node1 = Node.new('node1')
    node2 = Node.new('node2')
    node1.add_child('node2', node2)
    node3 = Node.new('node3')
    node2.add_child('node3', node3)
    node4 = Node.new('node4')
    node3.add_child('node4', node4)
    node5 = Node.new('node5')
    node4.add_child('node5', node5)

    node1.has_non_branching_descendants?.should == TRUE
  end

  it 'should show branching path' do
    node1 = Node.new('node1')
    node2 = Node.new('node2')
    node1.add_child('node2', node2)
    node3 = Node.new('node3')
    node2.add_child('node3', node3)
    node4 = Node.new('node4')
    node5 = Node.new('node5')
    node3.add_child('node4', node4)
    node3.add_child('node5', node5)

    node1.has_non_branching_descendants?.should == FALSE
  end

end