# frozen_string_literal: true

module Consolidatable
  class Consolidation < ActiveRecord::Base
    belongs_to :consolidatable, polymorphic: true, validate: { presence: true }

    def self.consolidate_them_all
      Consolidation
        .all
        .distinct
        .pluck(:consolidatable_type)
        .each do |klass|
          glass = klass.constantize
          glass
            .send(:class_variable_get, '@@consolidate_methods')
            .each { |m| glass.find_each { |g| g.send(m) } }
        end
    end

    def destale!(new_value)
      self.value = new_value
      self.updated_at = Time.current
      save
    end

    def stale?(not_older_than)
      updated_at < (Time.current - not_older_than)
    end

    def value
      send("#{var_type}_value")
    end

    def value=(value)
      send("#{var_type}_value=", value)
    end
  end
end
