class Objective < ApplicationRecord
  belongs_to :organization
  belongs_to :goal

  validates :name, presence: true

  def organization_name
    self.organization ? self.organization.name : nil
  end
end
