# frozen_string_literal: true

class AddFeeToForumSubRemoveBillingDate < ActiveRecord::Migration[6.0]
  def change
    add_column :forum_subscriptions, :fee, :integer, default: 0
    remove_column :forum_subscriptions, :annual_bill_date
    remove_column :forum_subscriptions, :monthly_bill_date
  end
end
