# frozen_string_literal: true

module Researches
  class NextResearchLevelPointsCommand < BaseCommand
    attr_reader :total_research_levels

    def initialize(total_research_levels:)
      @total_research_levels = total_research_levels
    end

    def call
      10 + (total_research_levels * total_research_levels * Math.sqrt(total_research_levels)).round
    end
  end
end
