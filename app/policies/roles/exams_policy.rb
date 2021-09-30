# frozen_string_literal: true

class Roles::ExamsPolicy < ApplicationPolicy
  def index?
    not_basic?
  end

  def show?
    not_basic?
  end

  def create?
    not_basic?
  end

  def update?
    not_basic?
  end

  def destroy?
    not_basic?
  end

  def invite?
    not_basic?
  end

  def uninvite?
    not_basic?
  end
end
