class DocumentVersion < ApplicationRecord
  belongs_to :document
  belongs_to :user ,optional: true
end
