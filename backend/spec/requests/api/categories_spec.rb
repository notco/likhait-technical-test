require 'rails_helper'

RSpec.describe "Api::Categories", type: :request do
  describe "GET /api/categories" do
    let!(:food) { Category.create!(name: "Food") }
    let!(:transport) { Category.create!(name: "Transport") }
    let!(:supplies) { Category.create!(name: "Supplies") }

    it "returns all categories" do
      get "/api/categories"

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.length).to eq(3)
      expect(json.map { |c| c["name"] }).to include("Food", "Transport", "Supplies")
    end

    it "returns categories in alphabetical order" do
      get "/api/categories"

      json = JSON.parse(response.body)
      expect(json.map { |c| c["name"] }).to eq([ "Food", "Supplies", "Transport" ])
    end
  end

  describe "POST /api/categories" do
    context "with valid parameters" do
      let(:valid_params) do
        { category: { name: "Entertainment" } }
      end

      it "creates a new category" do
        expect {
          post "/api/categories", params: valid_params
        }.to change(Category, :count).by(1)
      end

      it "returns the created category" do
        post "/api/categories", params: valid_params

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["name"]).to eq("Entertainment")
        expect(json["id"]).to be_present
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        { category: { name: "" } }
      end

      it "does not create a category" do
        expect {
          post "/api/categories", params: invalid_params
        }.not_to change(Category, :count)
      end

      it "returns unprocessable entity status" do
        post "/api/categories", params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error messages" do
        post "/api/categories", params: invalid_params

        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
        expect(json["errors"]).to include("Name can't be blank")
      end
    end

    context "with missing name parameter" do
      let(:invalid_params) do
        { category: { name: nil } }
      end

      it "returns unprocessable entity status" do
        post "/api/categories", params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Name can't be blank")
      end
    end
  end

  describe "PUT /api/categories/:id" do
    let!(:category) { Category.create!(name: "Food") }

    context "with valid parameters" do
      let(:valid_params) do
        { category: { name: "Groceries" } }
      end

      it "updates the category" do
        put "/api/categories/#{category.id}", params: valid_params

        category.reload
        expect(category.name).to eq("Groceries")
      end

      it "returns the updated category" do
        put "/api/categories/#{category.id}", params: valid_params

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json["name"]).to eq("Groceries")
        expect(json["id"]).to eq(category.id)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        { category: { name: "" } }
      end

      it "does not update the category" do
        original_name = category.name
        put "/api/categories/#{category.id}", params: invalid_params

        category.reload
        expect(category.name).to eq(original_name)
      end

      it "returns unprocessable entity status" do
        put "/api/categories/#{category.id}", params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error messages" do
        put "/api/categories/#{category.id}", params: invalid_params

        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
        expect(json["errors"]).to include("Name can't be blank")
      end
    end

    context "with non-existent category id" do
      it "returns not found status" do
        put "/api/categories/99999", params: { category: { name: "Test" } }
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE /api/categories/:id" do
    let!(:category) { Category.create!(name: "Food") }

    it "deletes the category" do
      expect {
        delete "/api/categories/#{category.id}"
      }.to change(Category, :count).by(-1)
    end

    it "returns no content status" do
      delete "/api/categories/#{category.id}"

      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_empty
    end

    context "when category has associated expenses" do
      let!(:expense) do
        category.expenses.create!(
          amount: 100,
          description: "Lunch",
          date: Date.today
        )
      end

      it "deletes the category and its expenses" do
        expect {
          delete "/api/categories/#{category.id}"
        }.to change(Category, :count).by(-1)
         .and change(Expense, :count).by(-1)
      end
    end

    context "with non-existent category id" do
      it "returns not found status" do
        delete "/api/categories/99999"
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
