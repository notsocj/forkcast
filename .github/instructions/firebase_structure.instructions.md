---
applyTo: '**'
---
applyTo: '**'

# ForkCast Firestore Schema Instructions
# AI must follow this schema when generating queries, functions, or database-related code.
# Do not invent collections or fields outside this structure, unless explicitly instructed.

collections:
  users:
    documentId: userId (string, Firebase Auth UID)
    fields:
      full_name: string (VARCHAR(100))
      email: string (VARCHAR(150), unique)
      password_hash: string (VARCHAR(255))
      phone_number: string (VARCHAR(20))
      gender: string (enum: ["Male", "Female", "Prefer not to say"])
      birthdate: timestamp
      height_cm: number (double)
      weight_kg: number (double)
      household_size: number (int)
      weekly_budget_min: number (int)
      weekly_budget_max: number (int)
      created_at: timestamp
      role: string (enum: ["user", "admin", "professional"])
      specialization: string (optional, for professionals)
    subcollections:
      health_conditions:
        documentId: conditionId (string)
        fields:
          condition_name: string (VARCHAR(100))
      meal_plans:
        documentId: mealPlanId (string)
        fields:
          meal_date: timestamp (date only)
          meal_type: string (enum: ["Breakfast", "Lunch", "Dinner", "Snack"])
          kcal_min: number (int)
          kcal_max: number (int)
          recipe_id: reference (→ recipes.recipeId)
      teleconsultations:
        documentId: teleconsultationId (string)
        fields:
          doctor_id: reference (→ users.userId)
          schedule_date: timestamp (date only)
          schedule_time: string | timestamp
          notes: string
          status: string (enum: ["Booked", "Confirmed", "Cancelled"])
          reference_no: string (unique)
      qna_questions:
        documentId: questionId (string)
        fields:
          question_text: string
          posted_at: timestamp
      availability:
        documentId: availabilityId (string)
        fields:
          date: timestamp (date only)
          start_time: string | timestamp
          end_time: string | timestamp

  recipes:
    documentId: recipeId (string)
    fields:
      recipe_name: string (VARCHAR(150))
      description: string (TEXT)
      kcal: number (int)
      servings: number (int)
      cooking_instructions: string
      created_at: timestamp
    subcollections:
      ingredients:
        documentId: recipeIngredientId (string)
        fields:
          ingredient_name: string
          quantity: number (double)
          unit: string

  ingredients:
    documentId: ingredientId (string)
    fields:
      ingredient_name: string (VARCHAR(150))
      category: string (VARCHAR(100))

  prices:
    documentId: priceId (string)
    fields:
      ingredient_id: reference (→ ingredients.ingredientId)
      price_per_kg: number (double)
      price_date: timestamp (date only)
      price_change_pct: number (double)

  qna_answers:
    documentId: answerId (string)
    fields:
      question_id: reference (→ users.qna_questions.questionId)
      expert_id: reference (→ users.userId)
      answer_text: string
      answered_at: timestamp

## Rules for ForkCast AI: 
- Only use the collections and fields defined above. 
- Use Firestore types: string, number, timestamp, reference, array, map. 
- Use subcollections where defined (e.g., meal_plans under users). 
- Foreign key–like relations use Firestore document references. 
- Never invent new fields, collections, or relationships unless explicitly instructed.