require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'associations' do
    it 'has many expenses' do
      association = Category.reflect_on_association(:expenses)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end
  end

  describe 'validations' do
    context 'when name is present' do
      it 'is valid' do
        category = Category.new(name: 'Food')
        expect(category).to be_valid
      end
    end

    context 'when name is nil' do
      it 'is invalid' do
        category = Category.new(name: nil)
        expect(category).not_to be_valid
        expect(category.errors[:name]).to include("can't be blank")
      end
    end

    context 'when name is empty string' do
      it 'is invalid' do
        category = Category.new(name: '')
        expect(category).not_to be_valid
        expect(category.errors[:name]).to include("can't be blank")
      end
    end

    context 'when name exceeds 100 characters' do
      it 'is invalid' do
        category = Category.new(name: 'a' * 101)
        expect(category).not_to be_valid
      end
    end

    context 'when name is exactly 100 characters' do
      it 'is valid' do
        category = Category.new(name: 'a' * 100)
        expect(category).to be_valid
      end
    end
  end

  describe 'dependent destroy' do
    it 'destroys associated expenses when category is destroyed' do
      category = Category.create!(name: 'Food')
      expense1 = category.expenses.create!(
        amount: 100,
        description: 'Lunch',
        date: Date.today
      )
      expense2 = category.expenses.create!(
        amount: 50,
        description: 'Snack',
        date: Date.today
      )

      expect { category.destroy }.to change { Expense.count }.by(-2)
      expect(Expense.exists?(expense1.id)).to be false
      expect(Expense.exists?(expense2.id)).to be false
    end
  end
end
