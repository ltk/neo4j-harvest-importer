class Relationship
  def initialize(params = {})
    @to_node = params.fetch(:to)
    @from_node = params.fetch(:from)
    @name = params.fetch(:named)
    @value = params.fetch(:identified_by)

    @key = params.fetch(:key, nil)
    @index_name = params.fetch(:indexed_as, nil)
  end

  def add_to(graph)
    return unless to_node && from_node

    graph.create_unique_relationship(index_name,
                                     key,
                                     value,
                                     name,
                                     from_node.add_to(graph),
                                     to_node.add_to(graph))
  end

  private
  attr_reader :from_node, :name, :to_node, :value

  def key
    @key || default_key
  end

  def index_name
    @index_name || default_index_name
  end

  def default_index_name
    "#{key}_#{name}_#{to_node.node_label}".downcase
  end

  def default_key
    from_node.node_label.downcase
  end
end
