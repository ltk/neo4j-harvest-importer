class Lab < Node::Named
  @@labs = []

  private

  def self.instances
    @@labs
  end
end
