-- HomePilot AI — Full Database Schema
-- Run this against your PostgreSQL database

DROP TABLE IF EXISTS mortgage_estimates CASCADE;
DROP TABLE IF EXISTS saved_properties CASCADE;
DROP TABLE IF EXISTS recommendations CASCADE;
DROP TABLE IF EXISTS grant_programs CASCADE;
DROP TABLE IF EXISTS listings CASCADE;
DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255),
    name VARCHAR(255),
    income_range VARCHAR(255),
    employment_status VARCHAR(255),
    household_size INTEGER,
    credit_estimate INTEGER,
    preferred_location VARCHAR(255),
    rent_or_buy VARCHAR(10)
);

CREATE TABLE listings (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    price NUMERIC(12, 2) NOT NULL,
    location VARCHAR(255) NOT NULL,
    bedrooms INTEGER NOT NULL,
    bathrooms INTEGER NOT NULL,
    rent_or_buy VARCHAR(10) NOT NULL,
    image_url VARCHAR(500),
    description TEXT
);

CREATE TABLE grant_programs (
    id BIGSERIAL PRIMARY KEY,
    program_name VARCHAR(255) NOT NULL,
    eligibility_rules TEXT NOT NULL,
    coverage_amount NUMERIC(12, 2) NOT NULL
);

CREATE TABLE recommendations (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    listing_id BIGINT NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    score DOUBLE PRECISION NOT NULL
);

CREATE TABLE saved_properties (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    listing_id BIGINT NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    UNIQUE(user_id, listing_id)
);

CREATE TABLE mortgage_estimates (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    estimated_budget NUMERIC(12, 2) NOT NULL,
    monthly_payment NUMERIC(12, 2) NOT NULL
);
