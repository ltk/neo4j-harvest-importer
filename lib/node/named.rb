require "#{ROOT_PATH}/lib/node/base"

module Node
  class Named < Base
    attr_reader :name

    private

    def after_initialize(params)
      @name = params.fetch(:name)
    end

    def node_property_list
      [:name]
    end
  end
end
