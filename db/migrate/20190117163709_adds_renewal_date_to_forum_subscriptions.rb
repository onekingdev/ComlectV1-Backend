class AddsRenewalDateToForumSubscriptions < ActiveRecord::Migration
  def change
    add_column :forum_subscriptions, :renewal_date, :datetime
  end
end
