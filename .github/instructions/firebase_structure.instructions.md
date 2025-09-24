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
      bmi: number (double)
      household_size: number (int)
      weekly_budget_min: number (int)
      weekly_budget_max: number (int)
      created_at: timestamp
      role: string (enum: ["user", "admin", "professional"])
      # Professional-specific fields (only for role="professional")
      specialization: string (optional, for professionals)
      license_number: string (optional, for professionals)
      years_experience: number (optional, for professionals)
      consultation_fee: number (optional, for professionals, in PHP)
      bio: string (optional, for professionals)
      certifications: array (optional, array of certification strings)
      is_verified: boolean (optional, default false, for professionals)
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
          # FNRI Integration Fields
          pax: number (int, 1-10, number of people meal is prepared for)
          scaled_kcal: number (int, calories adjusted for PAX)
          original_kcal: number (int, base recipe calories)
          scaling_factor: number (double, PAX scaling multiplier)
          original_servings: number (int, base recipe servings)
          scaled_servings: number (int, servings adjusted for PAX)
          # Health Condition Safety Metadata (boolean flags from FNRI data)
          is_diabetes_safe: boolean
          is_hypertension_safe: boolean
          is_obesity_safe: boolean
          is_underweight_safe: boolean
          is_heart_disease_safe: boolean
          is_anemia_safe: boolean
          is_osteoporosis_safe: boolean
          is_none_safe: boolean
          # Additional Meal Metadata
          recipe_name: string (meal name for easy identification)
          amount: number (double, serving amount)
          measurement: string (serving unit)
          logged_at: timestamp (when meal was logged)
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

  qna_questions:
    documentId: questionId (string)
    fields:
      question_text: string
      posted_at: timestamp
      user_id: reference (→ users.userId)
      user_name: string (denormalized for quick access)
      user_specialization: string (optional, for professionals)

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
      question_id: reference (→ qna_questions.questionId)
      expert_id: reference (→ users.userId)
      expert_name: string (denormalized for quick access)
      expert_specialization: string (optional, for professionals)
      answer_text: string
      answered_at: timestamp

  # Professional-specific collections
  consultations:
    documentId: consultationId (string)
    fields:
      patient_id: reference (→ users.userId)
      professional_id: reference (→ users.userId)
      consultation_date: timestamp (date only)
      consultation_time: string (time slot, e.g., "10:00 AM")
      duration: number (int, duration in minutes)
      topic: string (consultation topic/reason)
      status: string (enum: ["Scheduled", "Confirmed", "In Progress", "Completed", "Cancelled"])
      reference_no: string (unique reference number)
      notes: string (optional, consultation notes)
      patient_name: string (denormalized for quick access)
      patient_age: number (optional, int)
      patient_contact: string (optional, email/phone)
      created_at: timestamp
      updated_at: timestamp

  professional_availability:
    documentId: availabilityId (string)
    fields:
      professional_id: reference (→ users.userId)
      day_of_week: string (enum: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"])
      time_slot: string (e.g., "9:00 AM")
      is_available: boolean (true if available, false if blocked)
      updated_at: timestamp

  patient_notes:
    documentId: noteId (string)
    fields:
      professional_id: reference (→ users.userId)
      patient_id: reference (→ users.userId)
      patient_name: string (denormalized for quick access)
      consultation_id: reference (→ consultations.consultationId, optional)
      note_text: string
      tags: array (array of tag strings, e.g., ["Weight Management", "Diabetes"])
      health_conditions: array (array of health condition strings)
      created_at: timestamp
      updated_at: timestamp

  special_dates:
    documentId: specialDateId (string)
    fields:
      professional_id: reference (→ users.userId)
      date: timestamp (date only)
      is_available: boolean (true for extra availability, false for blocked)
      reason: string (optional, reason for blocking/adding availability)
      created_at: timestamp

## Rules for ForkCast AI: 
- Only use the collections and fields defined above. 
- Use Firestore types: string, number, timestamp, reference, array, map. 
- Use subcollections where defined (e.g., meal_plans under users). 
- Foreign key–like relations use Firestore document references. 
- Never invent new fields, collections, or relationships unless explicitly instructed.

## FNRI Integration Notes:
- The meal_plans subcollection has been enhanced with FNRI (Food and Nutrition Research Institute) integration
- PAX scaling allows meals to be prepared for 1-10 people with dynamic nutrition adjustment
- Health condition safety flags are based on FNRI research data and binary classification (0=not recommended, 1=safe)
- All logged meals include health condition metadata for medical suitability tracking
- The PersonalizedMealService uses these fields for AI-powered health-aware meal recommendations
- PAX scaling affects: scaled_kcal, scaled_servings, ingredient quantities, and nutrition calculations