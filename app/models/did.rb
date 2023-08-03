class Did < ApplicationRecord
  validates :did_long_form, presence: true
  validates :signing_key, presence: true
  validates :recovery_key, presence: true
  validates :update_key, presence: true

  belongs_to :wallet
end
