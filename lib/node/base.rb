require 'neography'

module Node
  class Base
    def self.find_or_initialize(params = {})
      found_instance = instance_matching_params(params)
      return found_instance if found_instance

      new(params)
    end

    def initialize(params = {})
      self.class.instances << self
      before_initialize(params)
      after_initialize(params)
    end

    def add_to(graph)
      unless added_to_graph?
        #TODO: Fix this
        graph.add_label(node, node_label)
        @added_to_graph = true
      end

      node
    end

    def node
      @node ||= Neography::Node.create(node_properties)
    end

    def node_label
      self.class.name
    end

    private

    def self.instances
      []
    end

    def self.instance_matching_params(params)
      instances.find do |instance|
        comparisons = params.map do |key, value|
          instance.send(key) == value
        end

        !comparisons.include?(false)
      end
    end

    def before_initialize(params)
      #no op
    end

    def after_initialize(params)
      #no op
    end

    def node_property_list
      []
    end

    def node_properties
      properties = {}

      node_property_list.each do |property_name|
        properties[property_name] = send(property_name)
      end

      properties
    end

    def added_to_graph?
      !!@added_to_graph
    end
  end
end
