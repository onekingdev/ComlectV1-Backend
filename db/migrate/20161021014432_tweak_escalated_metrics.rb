# frozen_string_literal: true

class TweakEscalatedMetrics < ActiveRecord::Migration[6.0]
  def change
    replace_view :metrics_escalated_projects, version: 2, revert_to_version: 1
  end
end
