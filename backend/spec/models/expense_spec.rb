require 'rails_helper'

RSpec.describe Expense, type: :model do
  describe 'validations' do
    let(:category) { Category.create!(name: 'Food') }

    context 'when date is in the future' do
      it 'is invalid' do
        expense = Expense.new(
          amount: 100,
          description: 'Test expense',
          date: Date.tomorrow,
          category: category
        )
        
        expect(expense).not_to be_valid
        expect(expense.errors[:date]).to include("must be less than or equal to #{Date.today}")
      end
    end

    context 'when date is today' do
      it 'is valid' do
        expense = Expense.new(
          amount: 100,
          description: 'Test expense',
          date: Date.today,
          category: category
        )
        
        expect(expense).to be_valid
      end
    end

    context 'when date is in the past' do
      it 'is valid' do
        expense = Expense.new(
          amount: 100,
          description: 'Test expense',
          date: Date.yesterday,
          category: category
        )
        
        expect(expense).to be_valid
      end
    end
  end
end
