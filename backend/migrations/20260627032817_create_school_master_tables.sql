-- +goose Up
-- +goose StatementBegin

CREATE TABLE school_profiles (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    npsn VARCHAR(50),
    address TEXT,
    phone VARCHAR(30),
    email VARCHAR(150),
    website VARCHAR(150),
    logo_path TEXT,
    principal_name VARCHAR(150),
    treasurer_name VARCHAR(150),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_school_profiles_public_id UNIQUE (public_id)
);

CREATE TABLE academic_years (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_academic_years_public_id UNIQUE (public_id),
    CONSTRAINT uq_academic_years_name UNIQUE (name),
    CONSTRAINT chk_academic_years_date CHECK (end_date >= start_date)
);

CREATE TABLE semesters (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL DEFAULT gen_random_uuid(),
    academic_year_id BIGINT NOT NULL,
    name VARCHAR(30) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_semesters_public_id UNIQUE (public_id),
    CONSTRAINT fk_semesters_academic_year FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE CASCADE,
    CONSTRAINT uq_semesters_academic_year_name UNIQUE (academic_year_id, name),
    CONSTRAINT chk_semesters_name CHECK (name IN ('ganjil', 'genap')),
    CONSTRAINT chk_semesters_date CHECK (end_date >= start_date)
);

CREATE TABLE majors (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL DEFAULT gen_random_uuid(),
    code VARCHAR(30) NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_majors_public_id UNIQUE (public_id),
    CONSTRAINT uq_majors_code UNIQUE (code)
);

CREATE TABLE academic_classes (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL DEFAULT gen_random_uuid(),
    academic_year_id BIGINT NOT NULL,
    major_id BIGINT,
    name VARCHAR(100) NOT NULL,
    grade_level INTEGER NOT NULL,
    homeroom_teacher_name VARCHAR(150),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT uq_academic_classes_public_id UNIQUE (public_id),
    CONSTRAINT fk_academic_classes_academic_year FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE RESTRICT,
    CONSTRAINT fk_academic_classes_major FOREIGN KEY (major_id) REFERENCES majors(id) ON DELETE SET NULL,
    CONSTRAINT uq_academic_classes_year_name UNIQUE (academic_year_id, name)
);
CREATE INDEX idx_academic_classes_academic_year_id ON academic_classes(academic_year_id);
CREATE INDEX idx_academic_classes_major_id ON academic_classes(major_id);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS academic_classes CASCADE;
DROP TABLE IF EXISTS majors CASCADE;
DROP TABLE IF EXISTS semesters CASCADE;
DROP TABLE IF EXISTS academic_years CASCADE;
DROP TABLE IF EXISTS school_profiles CASCADE;
-- +goose StatementEnd
