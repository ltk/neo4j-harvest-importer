require 'pry'

module Harvest
  class TaskRecord
    def initialize(data)
      @data = data
    end

    def add_to(graph)
      if person.first_name == 'Lawson'
        # binding.pry
      end

      relationships.each do |relationship|
        relationship.add_to(graph)
      end
    end

    private

    attr_reader :data

    def task
      @task ||= Task.find_or_initialize(name: "#{project.name} ••• #{field('Task')}")
    end

    def person
      @person ||= Person.find_or_initialize(first_name: field('First name'), last_name: field('Last name'))
    end

    def client
      @client ||= Client.find_or_initialize(name: field('Client'))
    end

    def project
      @project ||= Project.find_or_initialize(name: field('Project'))
    end

    def lab
      @lab ||= Lab.find_or_initialize(name: lab_name) unless lab_name.empty?
    end

    def field(name)
      data[name.to_s]
    end

    def lab_name
      field 'Department'
    end

    def relationship_definitions
      [
        { from: project, to: client, named: 'belongs_to', identified_by: project.name },
        { from: person, to: client, named: 'worked_for', identified_by: person.full_name },
        { from: person, to: task, named: 'worked_on', identified_by: "#{person.full_name}_#{task.name}" },
        { from: task, to: project, named: 'part_of', identified_by: task.name },
        { from: person, to: lab, named: 'belongs_to', identified_by: person.full_name }
      ]
    end

    def relationships
      relationship_definitions.map do |relationship_params|
        Relationship.new(relationship_params)
      end
    end
  end
end
