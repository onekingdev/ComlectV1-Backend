# frozen_string_literal: true
ActiveAdmin.register Transaction do
  menu parent: 'Financials'

  actions :all, except: %i(new create)

  decorate_with Admin::TransactionDecorator

  filter :amount_in_cents
  filter :status, as: :select, collection: Transaction.statuses
  filter :processed_at
  filter :created_at
  filter :updated_at

  collection_action :process_pending, method: :post do
    Transaction.process_pending!
    redirect_to admin_transactions_path, notice: 'Done'
  end

  action_item :process_pending, only: :index do
    link_to 'Process Pending',
            process_pending_admin_transactions_path,
            method: :post,
            title: 'Process pending transactions on Stripe.'
  end

  index do
    id_column
    column :project, sortable: 'projects.title' do |transaction|
      link_to transaction.project, [:admin, transaction.project]
    end
    column :type do |transaction|
      transaction.parent_transaction_id.present? ? 'Specialist Payment' : 'Business Charge'
    end
    column :amount, sortable: :amount_in_cents, class: 'number' do |transaction|
      number_to_currency transaction.amount
    end
    column :status do |transaction|
      status_tag transaction.status, transaction.status_css_class
    end
    column :processed_at
    actions
  end
end
