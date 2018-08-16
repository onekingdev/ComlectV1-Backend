# frozen_string_literal: true

class Specialist::Rewards
  def self.calculate!(specialist)
    tier = RewardsTier.for(specialist.processed_transactions_amount)
    specialist.update(rewards_tier: tier)
  end

  def self.reset!(specialist)
    specialist.update(rewards_tier: RewardsTier.default)
  end
end
