require 'neography'

class GraphPopulator
  def initialize(records)
    @records = Array(records)
  end

  def populate
    reset_graph

    puts "Populatin'..."

    records.each_with_index do |record, i|
      puts "Record #{i} of #{records.count}"
      record.add_to(graph)
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


