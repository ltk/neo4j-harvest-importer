module Harvest
  class TaskRecord
    def initialize(data)
      @data = data
    end

    def stats
      {
        'date'  => date,
        'notes' => notes,
        'hours' => hours,
        'day'   => day,
        'month' => month,
        'year'  => year
      }
    end

    def date
      @date ||= Date.parse(field('Date'))
    end

    def day
      date.day
    end

    def month
      date.month
    end

    def year
      date.year
    end

    def notes
      field('Notes') || 'None'
    end

    def client
      @client ||= Client.find_or_initialize(name: field('Client'))
    end

    def project
      @project ||= Project.find_or_initialize(name: field('Project'))
    end

    def project_code
      field 'Project Code'
    end

    def task
      @task ||= Task.find_or_initialize(name: "#{project.name} | #{task_name}")
    end

    def task_name
      field('Task')
    end

    def hours
      (field('Hours') || 0).to_f
    end

    def person
      @person ||= Person.find_or_initialize(first_name: first_name, last_name: last_name)
    end

    def billable?
      field('Billable') == 'billable'
    end

    def employee_or_contractor
      field 'Employee vs Contractor'
    end

    def approved?
      field('Approved') == 'yes'
    end

    def hourly_rate
      field 'Hourly rate'
    end

    def lab
      @lab ||= Lab.find_or_initialize(name: field('Department'))
    end

    def currency
      field 'Currency'
    end

    def add_to(graph)
      relationships.each do |relationship|
        relationship.add_to(graph)
      end
    end

    private

    attr_reader :data

    def field(name)
      data[name.to_s]
    end

    def first_name
      field 'First name'
    end

    def last_name
      field 'Last name'
    end

    def relationship_definitions
      [
        { from: person, to: lab, named: 'belongs_to', identified_by: person.full_name },
        { from: project, to: client, named: 'belongs_to', identified_by: project.name },
        { from: person, to: client, named: 'worked_for', identified_by: person.full_name },
        { from: person, to: task, named: 'worked_on', identified_by: person.full_name },
        { from: task, to: project, named: 'part_of', identified_by: task.name }
      ]
    end

    def relationships
      relationship_definitions.map do |relationship_params|
        Relationship.new(relationship_params)
      end
    end
  end
end
