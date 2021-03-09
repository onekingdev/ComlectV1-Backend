# frozen_string_literal: true

class LocalProject < ApplicationRecord
  has_many :projects
  belongs_to :business
  has_one :visible_project, -> { where(status: Project.statuses[:published]).order(id: :desc).limit(1) }, class_name: 'Project'
  has_many :collaborators, source: :specialist, through: :projects, class_name: 'Specialist'

  enum status: {
    inprogress: 'inprogress',
    draft: 'draft',
    complete: 'complete',
    pending: 'pending'
  }

  def deep_status
    if projects.collect(&:pending?).include?(true)
      'pending'
    else
      status
    end
  end

  def cost
    visible_project.est_budget if visible_project.present?
  end
end
