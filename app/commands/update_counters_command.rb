# frozen_string_literal: true

class UpdateCountersCommand < BaseCommand
  attr_reader :object, :changes

  def initialize(object:, changes:)
    @object = object
    @changes = changes
  end

  def execute
    query = UpdateCountersQuery.new(object: object, changes: changes).sql
    sql_returning = " RETURNING #{changes.keys.join(', ')}"
    query += sql_returning

    result = object.class.connection.exec_query(query)
    # rows.first because we update only one project and the second first because we change one field
    result.rows.first.first
  end
end
