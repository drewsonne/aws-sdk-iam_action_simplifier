require 'yaml'

# Used to load a file from the resources folder in this gem.
class LoadStatic
  # Load a resource from the gem. If the resource is yaml, it will
  # be parsed, and structured daa will be loaded.
  #
  # @param [String] file relative path to resources
  # @return [String, Array, Hash] Contents of the resource
  def self.load(file)
    full_resource_name = resource_path(file)

    if ['.yml', '.yaml'].include? File.extname(full_resource_name)
      # If it's a yaml, parse the file.
      resource = YAML.load_file(full_resource_name)
      # If we have a root key, return the contents under that
      if resource.has_key?('root')
        resource = resource['root']
      end
    else
      resource = File.read(full_resource_name)
    end

    resource
  end

  # Given a list of products, load all the actions for that list.
  #
  # @param [Array<String>] products a list of products names
  # @return [Array<String>] a list of actions
  def self.load_products(products)
    actions = []
    products.each do |product|
      product_actions = load("actions/#{product}.yaml")
      # Set the actions in the form "product:action"
      product_action = product_actions.map do |action|
        "#{product}:#{action}"
      end
      actions.concat(product_action)
    end
    actions
  end

  # Builds an absolute path to a resource in the gem
  #
  # @param [String] file relative path to the required resurce
  # @return [String] Absolute path
  def self.resource_path(file)
    File.join(self.path_to_resources, file)
  end

  # Determine the path to the resources folder
  #
  # @return [String] Absolute path to resources folder
  def self.path_to_resources
    File.expand_path('../../../../../resources', __FILE__)
  end

end