require 'csv'
require 'neography'
require 'pry'

class Node
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

  def added_to_graph?
    !!@added_to_graph
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

  def node_label
    self.class.name
  end

  def node_properties
    properties = {}

    node_property_list.each do |property_name|
      properties[property_name] = send(property_name)
    end

    properties
  end
end

class NamedNode < Node
  attr_reader :name

  private

  def after_initialize(params)
    @name = params.fetch(:name)
  end

  def node_property_list
    [:name]
  end
end

class Person < Node
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

class Client < NamedNode
  @@clients = []

  private

  def self.instances
    @@clients
  end
end

class Project < NamedNode
  @@projects = []

  private

  def self.instances
    @@projects
  end
end

class Department < NamedNode
  @@departments = []

  private

  def self.instances
    @@departments
  end
end

class Importer
  def initialize(file_path)
    @file_path = File.path(file_path)
  end

  def import
    graph_populator.populate
  end

  private

  attr_reader :file_path
  attr_accessor :rows, :tasks

  def csv
    @csv ||= CSV.open(file_path, headers: :first_row)
  end

  def headers
    csv.headers
  end

  def harvest_task_records
    @harvest_task_records ||= begin
      [].tap do |records|
        csv.each do |row|
          records << HarvestTaskRecord.new(row)
        end
      end
    end
  end

  def graph_populator
    @graph_populator ||= GraphPopulator.new(harvest_task_records)
  end
end

class HarvestTaskRecord
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
    @task ||= Task.find_or_initialize(name: field('Task'))
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

  def department
    @department ||= Department.find_or_initialize(name: field('Department'))
  end

  def currency
    field 'Currency'
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
end

class GraphPopulator
  def initialize(records)
    @records = Array(records)
  end

  def populate
    reset_graph

    puts "Populatin'..."

    records.each_with_index do |record, i|
      puts "Record #{i} of #{records.count}"

      person = record.person.add_to(graph)
      client = record.client.add_to(graph)
      project = record.project.add_to(graph)
      department = record.department.add_to(graph)

      graph.create_unique_relationship('people_in_departments', 'person', record.person.full_name, 'belongs_to', person, department)
      graph.create_unique_relationship('project_for_client', 'project', record.project.name, 'belongs_to', project, client)
      graph.create_unique_relationship('worked_for_client', 'person', record.person.full_name, 'worked_for', person, client)
      work = graph.create_relationship("worked_on", person, project)

      graph.set_relationship_properties(work, record.stats)
    end
  end

  private

  attr_reader :records

  def graph
    @graph ||= Neography::Rest.new
  end

  def reset_graph
    puts 'Resetting...'
    graph.execute_query('start r=rel(*) delete r')
    graph.execute_query('start n=node(*) delete n')
  end
end

importer = Importer.new('report_2013Oct01_to_2013Dec31.csv')
importer.import
