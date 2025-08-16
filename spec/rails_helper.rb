# frozen_string_literal: true

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') unless Rails.env.test?

require 'spec_helper'
