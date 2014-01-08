require "#{ROOT_PATH}/lib/node/named"

class Client < Node::Named
  @@clients = []

  private

  def self.instances
    @@clients
  end
end
