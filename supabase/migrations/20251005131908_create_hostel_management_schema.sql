/*
  # Hostel Management System Database Schema

  ## Overview
  This migration creates the complete database structure for a hostel mess management system
  with two user roles: Admin (Manager) and User (Mess Member).

  ## 1. New Tables

  ### `admins`
  - `id` (uuid, primary key) - Auto-generated admin ID
  - `hostel_name` (text) - Name of the hostel
  - `full_name` (text) - Admin's full name
  - `email` (text, unique) - Admin email for login
  - `auth_id` (uuid, foreign key) - Links to Supabase auth.users
  - `created_at` (timestamptz) - Account creation timestamp

  ### `members`
  - `id` (uuid, primary key) - Auto-generated member ID
  - `hostel_id` (uuid, foreign key) - References admins table
  - `name` (text) - Member's name
  - `email` (text, unique) - Member email for login
  - `auth_id` (uuid, foreign key) - Links to Supabase auth.users
  - `bazar_amount` (numeric, default 0) - Monthly bazar contribution
  - `created_at` (timestamptz) - Account creation timestamp

  ### `meals`
  - `id` (uuid, primary key) - Auto-generated meal record ID
  - `hostel_id` (uuid, foreign key) - References admins table
  - `date` (date) - Date of the meal
  - `created_at` (timestamptz) - Record creation timestamp

  ### `meal_records`
  - `id` (uuid, primary key) - Auto-generated record ID
  - `meal_id` (uuid, foreign key) - References meals table
  - `member_id` (uuid, foreign key) - References members table
  - `day_meal` (boolean, default false) - Did member take day meal
  - `night_meal` (boolean, default false) - Did member take night meal
  - `created_at` (timestamptz) - Record creation timestamp

  ### `expenses`
  - `id` (uuid, primary key) - Auto-generated expense ID
  - `hostel_id` (uuid, foreign key) - References admins table
  - `description` (text) - Expense description (gas, electricity, rent, etc.)
  - `amount` (numeric) - Expense amount
  - `date` (date) - Date of expense
  - `created_at` (timestamptz) - Record creation timestamp

  ### `notices`
  - `id` (uuid, primary key) - Auto-generated notice ID
  - `hostel_id` (uuid, foreign key) - References admins table
  - `title` (text) - Notice title
  - `message` (text) - Notice content
  - `created_at` (timestamptz) - Notice creation timestamp

  ## 2. Security
  - Enable Row Level Security (RLS) on all tables
  - Admins can only access their own hostel data
  - Members can only access their own hostel data
  - Members have read-only access to meals and notices
  - Members can update their own meal records

  ## 3. Indexes
  - Index on email fields for faster authentication lookups
  - Index on foreign keys for faster joins
  - Index on date fields for meal and expense queries
*/
-- Create admins table
CREATE TABLE IF NOT EXISTS admins (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  hostel_name text NOT NULL,
  full_name text NOT NULL,
  email text UNIQUE NOT NULL,
  auth_id uuid UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_admins_email ON admins(email);
CREATE INDEX IF NOT EXISTS idx_admins_auth_id ON admins(auth_id);

-- Enable Row Level Security
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

-- RLS Policies for admins table
CREATE POLICY "Admins can view own profile"
  ON admins FOR SELECT
  TO authenticated
  USING (auth.uid() = auth_id);

CREATE POLICY "Admins can update own profile"
  ON admins FOR UPDATE
  TO authenticated
  USING (auth.uid() = auth_id)
  WITH CHECK (auth.uid() = auth_id);

CREATE POLICY "Admins can insert own profile"
  ON admins FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = auth_id);

  -- Create members table
CREATE TABLE IF NOT EXISTS members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  hostel_id uuid NOT NULL REFERENCES admins(id) ON DELETE CASCADE,
  name text NOT NULL,
  email text UNIQUE NOT NULL,
  auth_id uuid UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  bazar_amount numeric DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_members_email ON members(email);
CREATE INDEX IF NOT EXISTS idx_members_auth_id ON members(auth_id);
CREATE INDEX IF NOT EXISTS idx_members_hostel_id ON members(hostel_id);

-- Enable Row Level Security
ALTER TABLE members ENABLE ROW LEVEL SECURITY;

-- RLS Policies for members table
CREATE POLICY "Admins can view their hostel members"
  ON members FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.id = members.hostel_id
      AND admins.auth_id = auth.uid()
    )
    OR auth.uid() = members.auth_id
  );

CREATE POLICY "Admins can insert members"
  ON members FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.id = members.hostel_id
      AND admins.auth_id = auth.uid()
    )
  );

CREATE POLICY "Admins can update their hostel members"
  ON members FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.id = members.hostel_id
      AND admins.auth_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.id = members.hostel_id
      AND admins.auth_id = auth.uid()
    )
  );

CREATE POLICY "Admins can delete their hostel members"
  ON members FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admins
      WHERE admins.id = members.hostel_id
      AND admins.auth_id = auth.uid()
    )
  );