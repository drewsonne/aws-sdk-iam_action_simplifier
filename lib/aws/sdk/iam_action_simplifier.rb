require 'aws/sdk/iam_action_simplifier/version'
require 'aws/sdk/iam_action_simplifier/load_static'
require 'aws/sdk/iam_action_simplifier/tree'

module Aws
  module Sdk
    module IamActionSimplifier
      class Actions
        def initialize(action_list)
          @action_list = action_list
        end

        def simplify()
          provided_products = _get_product_prefixes(@action_list)
          actions = LoadStatic.load_products(provided_products)
          # Generate our tree
          action_tree = Tree.new

          # Inject all actions into the tree
          action_tree.add_actions(actions, :action_path => FALSE)
          # Inject our actions into the tree
          action_tree.add_actions(@action_list, :action_path => TRUE)

          # 1 - Walk all nodes, and walk them by highest rank. Priorities Top-to-Bottom, Left-to-Right.
          simplified_action_nodes = []
          action_tree.walk do |walker, node|
            if node.all_descendents_in_action?(TRUE)
              walker.skip_descendents_of(node)
              simplified_action_nodes << node
            end
          end

          simplified_action_nodes.map { |node| node.action }
        end

        def _sort_into_paths(nodes)

          leafs = nodes.select { |n| n.is_action_leaf? }

          leafs.first.find_common_parent(leafs)

          path_nodes = []
          nodes.each do |node|
            unless path_nodes.length > 0
              path_nodes.concat(node.path)
            else
              existing_nodes = path.nodes.select { |n| n.equal? node }
              if existing_nodes.length == 0
                path_nodes.concat(node.path)
              end
            end
          end

          path_nodes = path_nodes.uniq
          path_nodes
        end

        # Given a list of actions, along with their product prefixes,
        # return a list of unique products
        #
        # @param [Array<String>] action_list List of action strings
        # @return [Array<String>] A list of unique products
        def _get_product_prefixes(action_list)
          action_list.map do |action|
            product, action = action.split(':')
            if action.nil?
              raise ArgumentError, "String is missing product or action ('#{action}')"
            end
            product
          end.uniq do |product|
            product
          end.sort
        end

        # # Given a list of actions, build a tree of the common words in the action
        # #
        # # @param [Array<String>] actions List of action strings
        # # @param [Boolean] action_path If false, then this is the list of all AWS actions.
        # #                              If true, then this is the actions are are trying to simplify.
        # # @return [Hash] a hash of hashes, describing the common words int he aciton list.
        # def _build_action_tree(actions, action_path)
        #   tree.add_actions(actions, :action_path => action_path)
        #   tree
        # end

      end
    end
  end
end
