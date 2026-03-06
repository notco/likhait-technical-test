import React, { useState, useEffect } from "react";
import { fetchCategories, createCategory } from "../services/api";
import { COLORS } from "../constants/colors";
import { CategoryTable } from "../components/CategoryTable";
import { CategoryForm } from "../components/CategoryForm";
import { Modal, Button } from "../vibes";

interface Category {
  id: number;
  name: string;
}

const CategoriesPage: React.FC = () => {
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);

  useEffect(() => {
    fetchCategoriesData();
  }, []);

  const fetchCategoriesData = async () => {
    try {
      setLoading(true);
      const categoriesData = await fetchCategories();
      setCategories(categoriesData);
    } catch (error) {
      console.error("Error fetching categories:", error);
    } finally {
      setLoading(false);
    }
  };

  const pageStyle: React.CSSProperties = {
    padding: "48px 64px",
    minHeight: "100vh",
    background: COLORS.secondary.s01,
  };

  const handleAddCategory = async (name: string) => {
    try {
      await createCategory(name);
      setIsModalOpen(false);
      fetchCategoriesData();
    } catch (error) {
      console.error("Error creating category:", error);
      throw error;
    }
  };

  const headerStyle: React.CSSProperties = {
    display: "flex",
    alignItems: "center",
    justifyContent: "space-between",
    marginBottom: "32px",
  };

  const titleStyle: React.CSSProperties = {
    fontSize: "40px",
    fontWeight: 700,
    color: COLORS.secondary.s10,
    margin: 0,
  };

  const loadingStyle: React.CSSProperties = {
    display: "flex",
    justifyContent: "center",
    alignItems: "center",
    padding: "48px",
    fontSize: "18px",
    color: COLORS.secondary.s08,
  };

  return (
    <div style={pageStyle}>
      <div style={headerStyle}>
        <h1 style={titleStyle}>Categories</h1>
        <Button variant="primary" onClick={() => setIsModalOpen(true)}>
          Add Category
        </Button>
      </div>

      {loading ? (
        <div style={loadingStyle}>Loading...</div>
      ) : (
        <CategoryTable 
          categories={categories} 
          onCategoryUpdated={fetchCategoriesData}
        />
      )}

      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title="Add New Category"
      >
        <CategoryForm
          onSubmit={handleAddCategory}
          onCancel={() => setIsModalOpen(false)}
        />
      </Modal>
    </div>
  );
};

export default CategoriesPage;
