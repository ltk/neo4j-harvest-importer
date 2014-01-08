class Project < Node::Named
  @@projects = []

  private

  def self.instances
    @@projects
  end
end
