class Task < Node::Named
  @@tasks = []

  private

  def self.instances
    @@tasks
  end
end
