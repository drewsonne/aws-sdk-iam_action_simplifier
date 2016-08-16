class Node

  attr_accessor :parent
  attr_accessor :in_action_path
  attr_reader :name

  @name
  @parent
  @in_action_path

  @_children

  def initialize(name=nil)
    @_children = []
    @in_action_path = FALSE
    @name = name
    @parent = nil
  end

  def root?
    @parent.nil?
  end

  def rank
    if @parent.nil?
      0
    else
      @parent.rank + 1
    end
  end

  def has_as_parent(node)
    if @parent.nil?
      return FALSE
    end

    if @parent == node
      TRUE
    else
      @parent.has_as_parent(node)
    end
  end

  def add_child(key, node)
    @_children << {:key => key, :node => node}
    node.parent = self
  end

  def child?(key)
    @_children.select { |node| node[:key] == key }.length > 0
  end

  def child(key)
    @_children.select { |node| node[:key] == key }.first[:node]
  end

  def children
    @_children.map { |node| node[:node] }
  end

  def add_actions(actions, _options)
    actions.each do |action|
      add_action(action, _options)
    end
  end

  def add_action(action, _options)
    action_words = action.split(/(?=[A-Z*]|:)/).select { |word| word != ':' }
    add_action_parts(action_words, _options)
  end

  def add_action_parts(action_words, _options)
    node_name = action_words.shift
    if node_name.nil?
      return
    end
    if (node_name == '*') and _options.has_key?(:action_path)
      descendants.each do |node|
        node.in_action_path = (node.in_action_path or _options[:action_path])
      end
    else
      unless child?(node_name)
        new_node = Node.new(node_name)
        new_node.parent = self
        add_child(node_name, new_node)
      end

      node = child(node_name)
      if _options.has_key?(:action_path)
        node.in_action_path = (node.in_action_path or _options[:action_path])
      end
      if action_words.length > 0
        child(node_name).add_action_parts(action_words, _options)
      end
    end

  end


  ## Conditions to determine if the node should be used in summary

  #
  def all_siblings_in_action?
    if root?
      TRUE
    else
      @parent.all_children_in_action?
    end
  end

  def all_children_in_action?
    return_value = TRUE
    children.each { |node| return_value = (return_value and node.in_action_path) }
    return_value
  end

  # def any_sibling_not_in_action?
  #   not all_siblings_in_action?
  # end

  def leaf?
    children.length == 0
  end

  def all_descendents_in_action?(inclusive=FALSE)
    children.reduce(inclusive ? in_action_path : TRUE) do |return_value, node|
      return_value and node.all_descendents_in_action?(inclusive)
    end
  end

  def has_non_branching_descendants?
    descendants.reduce(TRUE) do |one_child_policy,node|
      one_child_policy and (node.children.length <= 1)
    end
  end

  # def lowest_ranked_common_action_pattern?
  #   # a - at least 1 sibling is not in action path
  #   # b - is leaf
  #   # c - all descendents are in action path
  #   #
  #   # if (a and b) or (not b and c and a)
  #   a = any_sibling_not_in_action?
  #   b = leaf?
  #   c = all_descendents_in_action?
  #   (a and b) or (a and (not b) and c)
  # end

  def cardinality
    children_cardinality = children.reduce(0) do |sum, child|
      sum += child.cardinality
    end
    self_cardinality = @in_action_path ? 0 : 1
    children_cardinality + self_cardinality
  end

  def path
    path_to_root = []
    unless @parent.nil?
      path_to_root.concat(@parent.path)
    end
    path_to_root << self
    path_to_root.select! { |node| not node.name.nil? }
    path_to_root
  end

  def action

    if (not leaf?) and has_non_branching_descendants?
      path_to_leaf = descendants
      leaf = path_to_leaf.sort do |node|
        -node.rank
      end.last
      leaf.action
    else
      action_string = ""
      found_product = FALSE
      path.each do |node|
        if found_product
          action_string += node.name
        else
          action_string += "#{node.name}:"
          found_product = TRUE
        end
      end
      if children.length > 0
        action_string += "*"
      end
      action_string
    end
  end

  def descendants
    _descendants = []
    each do |node|
      _descendants << node
    end
    _descendants
  end

  ## Implement Enumerables

  def each(&block)
    yield self
    children.each do |node|
      node.each(&block)
    end
  end

  def select
    out = []
    each do |node|
      result = yield(node)
      if result
        out << node
      end
    end
    out
  end

  def to_s
    id = '%x' % (object_id << 1)
    id = id.rjust(14, padstr='0')
    "#<Node:0x#{id}:{#{action}}>"
  end


end

class Tree < Node

  def walk(&block)
    walker = TreeWalker.new(self)
    walker.each do |node|
      block.call(walker, node)
    end
  end
end

class TreeWalker

  @tree
  @excluded_nodes = []

  def initialize(tree)
    @tree = tree
    @excluded_nodes = []
  end

  def each(&block)
    @tree.each do |node|
      if allowed(node)
        yield node
      end
    end
  end

  def allowed(node)
    not @excluded_nodes.include?(node)
  end

  def skip_descendents_of(node)
    @excluded_nodes.concat(node.descendants)
  end

end
