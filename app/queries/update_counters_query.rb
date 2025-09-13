# frozen_string_literal: true

class UpdateCountersQuery < BaseQuery
  attr_reader :object, :changes

  def initialize(object:, changes:)
    @object = object
    @changes = changes
  end

  def query
    setters = []
    arel = object.class.arel_table
    changes.each do |key, value|
      next unless value
      raise ArgumentError, "no such attribute #{key} to update" unless object.has_attribute?(key)

      setters << [arel[key], sum_up(arel, key, value)]
    end

    update_manager = Arel::UpdateManager.new
    update_manager.table(arel)
    update_manager.where(arel[:id].eq(object.id))
    update_manager.set(setters)
  end

  private

  def sum_up(table, key, value)
    Arel.sql(
      addition(
        coalesce(table[key], Arel::Nodes.build_quoted(0)),
        Arel::Nodes.build_quoted(value)
      ).to_sql
    )
  end
end
