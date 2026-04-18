CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
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
    rent_or_buy VARCHAR(10) NOT NULL
);

CREATE TABLE grant_programs (
    id BIGSERIAL PRIMARY KEY,
    program_name VARCHAR(255) NOT NULL,
    eligibility_rules TEXT NOT NULL,
    coverage_amount NUMERIC(12, 2) NOT NULL
);

CREATE TABLE recommendations (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    listing_id BIGINT NOT NULL REFERENCES listings(id),
    score DOUBLE PRECISION NOT NULL
);

CREATE TABLE saved_properties (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    listing_id BIGINT NOT NULL REFERENCES listings(id)
);

CREATE TABLE mortgage_estimates (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    estimated_budget NUMERIC(12, 2) NOT NULL,
    monthly_payment NUMERIC(12, 2) NOT NULL
);
