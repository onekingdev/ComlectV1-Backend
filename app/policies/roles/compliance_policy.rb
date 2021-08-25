# frozen_string_literal: true

class Roles::CompliancePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    not_basic?
  end

  def update?
    not_basic?
  end

  def download?
    not_basic?
  end

  def publish?
    not_basic?
  end
end
