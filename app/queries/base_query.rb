# frozen_string_literal: true

class BaseQuery
  attr_reader :relation

  def initialize(relation = default_relation)
    @relation = relation
  end

  def query
    relation
  end

  def cache_query
    query
  end

  def default_relation
    raise NotImplementedError, 'must be implemented in subclasses'
  end

  def sql
    query.to_sql
  end

  private

  def addition(left, right)
    Arel::Nodes::Addition.new(left, right)
  end

  def coalesce(*)
    named_function('coalesce', *)
  end

  def named_function(name, *args)
    Arel::Nodes::NamedFunction.new(name, args)
  end
end
