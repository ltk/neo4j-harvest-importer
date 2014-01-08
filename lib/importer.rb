require 'csv'

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
          records << Harvest::TaskRecord.new(row)
        end
      end
    end
  end

  def graph_populator
    @graph_populator ||= GraphPopulator.new(harvest_task_records)
  end
end
