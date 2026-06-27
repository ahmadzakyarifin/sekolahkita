-- +goose Up
-- +goose StatementBegin

CREATE TABLE students (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL DEFAULT gen_random_uuid(),
    user_id BIGINT,
    nis VARCHAR(50) NOT NULL,
    nisn VARCHAR(50),
    name VARCHAR(150) NOT NULL,
    gender VARCHAR(20),
    birth_place VARCHAR(100),
    birth_date DATE,
    address TEXT,
    phone VARCHAR(30),
    status VARCHAR(30) NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT uq_students_public_id UNIQUE (public_id),
    CONSTRAINT uq_students_nis UNIQUE (nis),
    CONSTRAINT uq_students_nisn UNIQUE (nisn),
    CONSTRAINT fk_students_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT chk_students_gender CHECK (gender IS NULL OR gender IN ('male', 'female')),
    CONSTRAINT chk_students_status CHECK (status IN ('active', 'inactive', 'graduated', 'transferred', 'dropped_out'))
);
CREATE INDEX idx_students_user_id ON students(user_id);
CREATE INDEX idx_students_status ON students(status);

CREATE TABLE guardians (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL DEFAULT gen_random_uuid(),
    user_id BIGINT,
    name VARCHAR(150) NOT NULL,
    phone VARCHAR(30),
    email VARCHAR(150),
    occupation VARCHAR(150),
    address TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT uq_guardians_public_id UNIQUE (public_id),
    CONSTRAINT uq_guardians_user_id UNIQUE (user_id),
    CONSTRAINT fk_guardians_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);
CREATE INDEX idx_guardians_user_id ON guardians(user_id);
CREATE INDEX idx_guardians_phone ON guardians(phone);

CREATE TABLE student_guardians (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT NOT NULL,
    guardian_id BIGINT NOT NULL,
    relationship VARCHAR(50) NOT NULL,
    is_primary_contact BOOLEAN NOT NULL DEFAULT FALSE,
    can_login BOOLEAN NOT NULL DEFAULT FALSE,
    can_receive_notification BOOLEAN NOT NULL DEFAULT TRUE,
    can_make_payment BOOLEAN NOT NULL DEFAULT TRUE,
    can_view_invoice BOOLEAN NOT NULL DEFAULT TRUE,
    can_open_support_ticket BOOLEAN NOT NULL DEFAULT TRUE,
    is_emergency_contact BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_student_guardians_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_student_guardians_guardian FOREIGN KEY (guardian_id) REFERENCES guardians(id) ON DELETE CASCADE,
    CONSTRAINT uq_student_guardians UNIQUE (student_id, guardian_id),
    CONSTRAINT chk_student_guardians_relationship CHECK (relationship IN ('father', 'mother', 'guardian', 'grandfather', 'grandmother', 'other'))
);
CREATE INDEX idx_student_guardians_student_id ON student_guardians(student_id);
CREATE INDEX idx_student_guardians_guardian_id ON student_guardians(guardian_id);

CREATE TABLE class_memberships (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT NOT NULL,
    class_id BIGINT NOT NULL,
    academic_year_id BIGINT NOT NULL,
    semester_id BIGINT,
    start_date DATE,
    end_date DATE,
    status VARCHAR(30) NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_class_memberships_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_class_memberships_class FOREIGN KEY (class_id) REFERENCES academic_classes(id) ON DELETE RESTRICT,
    CONSTRAINT fk_class_memberships_academic_year FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE RESTRICT,
    CONSTRAINT fk_class_memberships_semester FOREIGN KEY (semester_id) REFERENCES semesters(id) ON DELETE SET NULL,
    CONSTRAINT chk_class_memberships_status CHECK (status IN ('active', 'moved', 'completed', 'inactive'))
);
CREATE INDEX idx_class_memberships_student_id ON class_memberships(student_id);
CREATE INDEX idx_class_memberships_class_id ON class_memberships(class_id);
CREATE INDEX idx_class_memberships_academic_year_id ON class_memberships(academic_year_id);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS class_memberships CASCADE;
DROP TABLE IF EXISTS student_guardians CASCADE;
DROP TABLE IF EXISTS guardians CASCADE;
DROP TABLE IF EXISTS students CASCADE;
-- +goose StatementEnd
