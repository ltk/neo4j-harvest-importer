class Person < Node::Base
  attr_reader :first_name, :last_name

  @@people = []

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def self.instances
    @@people
  end

  def after_initialize(params)
    @first_name = params.fetch(:first_name)
    @last_name = params.fetch(:last_name)
  end

  def node_property_list
    [:first_name, :last_name, :full_name]
  end
end
