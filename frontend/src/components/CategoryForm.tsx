/**
 * Form component for adding/editing categories
 */

import React, { useState } from "react";
import { TextField, Button } from "../vibes";

interface CategoryFormProps {
  initialName?: string;
  onSubmit: (name: string) => Promise<void>;
  onCancel?: () => void;
  submitLabel?: string;
}

export function CategoryForm({
  initialName = "",
  onSubmit,
  onCancel,
  submitLabel = "Add Category",
}: CategoryFormProps) {
  const [name, setName] = useState(initialName);
  const [error, setError] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    if (!name.trim()) {
      setError("Category name is required");
      return;
    }

    try {
      setIsSubmitting(true);
      await onSubmit(name.trim());
    } catch (err) {
      setError("Failed to save category");
    } finally {
      setIsSubmitting(false);
    }
  };

  const formStyle: React.CSSProperties = {
    display: "flex",
    flexDirection: "column",
    gap: "1rem",
  };

  const buttonGroupStyle: React.CSSProperties = {
    display: "flex",
    gap: "0.5rem",
    marginTop: "0.5rem",
  };


  return (
    <form onSubmit={handleSubmit} style={formStyle}>
      <TextField
        label="Name"
        type="text"
        placeholder="Enter category name"
        value={name}
        onChange={(e) => setName(e.target.value)}
        error={error}
        fullWidth
        required
      />

      <div style={buttonGroupStyle}>
        <Button
          type="submit"
          variant="primary"
          disabled={isSubmitting}
          fullWidth
        >
          {isSubmitting ? "Submitting..." : submitLabel}
        </Button>
        {onCancel && (
          <Button
            type="button"
            variant="secondary"
            onClick={onCancel}
            disabled={isSubmitting}
          >
            Cancel
          </Button>
        )}
      </div>
    </form>
  );
}
