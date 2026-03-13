# frozen_string_literal: true

module Researches
  class NextResearchLevelPointsCommand < BaseCommand
    # Flat base cost every research level requires regardless of total levels
    BASE_RESEARCH_COST = 10

    attr_reader :total_research_levels

    def initialize(total_research_levels:)
      @total_research_levels = total_research_levels
    end

    def call
      # Cost grows super-linearly: base + n² * √n, so each level is increasingly expensive
      BASE_RESEARCH_COST + (total_research_levels * total_research_levels * Math.sqrt(total_research_levels)).round
    end
  end
end
