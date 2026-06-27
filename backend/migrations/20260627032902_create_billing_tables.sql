-- +goose Up
-- +goose StatementBegin

CREATE TABLE billing_types (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    is_recurring BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_billing_types_public_id UNIQUE (public_id),
    CONSTRAINT uq_billing_types_code UNIQUE (code)
);

CREATE TABLE billing_rules (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL DEFAULT gen_random_uuid(),
    billing_type_id BIGINT NOT NULL,
    academic_year_id BIGINT NOT NULL,
    class_id BIGINT,
    major_id BIGINT,
    name VARCHAR(150) NOT NULL,
    amount NUMERIC(14,2) NOT NULL DEFAULT 0,
    frequency VARCHAR(30) NOT NULL DEFAULT 'once',
    due_day INTEGER,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_billing_rules_public_id UNIQUE (public_id),
    CONSTRAINT fk_billing_rules_billing_type FOREIGN KEY (billing_type_id) REFERENCES billing_types(id) ON DELETE RESTRICT,
    CONSTRAINT fk_billing_rules_academic_year FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE RESTRICT,
    CONSTRAINT fk_billing_rules_class FOREIGN KEY (class_id) REFERENCES academic_classes(id) ON DELETE SET NULL,
    CONSTRAINT fk_billing_rules_major FOREIGN KEY (major_id) REFERENCES majors(id) ON DELETE SET NULL,
    CONSTRAINT chk_billing_rules_frequency CHECK (frequency IN ('once', 'monthly', 'semester', 'yearly')),
    CONSTRAINT chk_billing_rules_amount CHECK (amount >= 0)
);
CREATE INDEX idx_billing_rules_billing_type_id ON billing_rules(billing_type_id);
CREATE INDEX idx_billing_rules_academic_year_id ON billing_rules(academic_year_id);

CREATE TABLE invoice_generation_batches (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL DEFAULT gen_random_uuid(),
    academic_year_id BIGINT NOT NULL,
    semester_id BIGINT,
    billing_rule_id BIGINT,
    generated_by BIGINT,
    title VARCHAR(200) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'processing',
    total_students INTEGER NOT NULL DEFAULT 0,
    total_invoices INTEGER NOT NULL DEFAULT 0,
    total_amount NUMERIC(14,2) NOT NULL DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    CONSTRAINT uq_invoice_generation_batches_public_id UNIQUE (public_id),
    CONSTRAINT fk_invoice_generation_batches_academic_year FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE RESTRICT,
    CONSTRAINT fk_invoice_generation_batches_semester FOREIGN KEY (semester_id) REFERENCES semesters(id) ON DELETE SET NULL,
    CONSTRAINT fk_invoice_generation_batches_billing_rule FOREIGN KEY (billing_rule_id) REFERENCES billing_rules(id) ON DELETE SET NULL,
    CONSTRAINT fk_invoice_generation_batches_generated_by FOREIGN KEY (generated_by) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT chk_invoice_generation_batches_status CHECK (status IN ('processing', 'completed', 'failed', 'cancelled'))
);

CREATE TABLE invoices (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL DEFAULT gen_random_uuid(),
    invoice_number VARCHAR(100) NOT NULL,
    student_id BIGINT NOT NULL,
    academic_year_id BIGINT NOT NULL,
    semester_id BIGINT,
    generation_batch_id BIGINT,
    title VARCHAR(200) NOT NULL,
    issue_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE,
    subtotal_amount NUMERIC(14,2) NOT NULL DEFAULT 0,
    discount_amount NUMERIC(14,2) NOT NULL DEFAULT 0,
    total_amount NUMERIC(14,2) NOT NULL DEFAULT 0,
    paid_amount NUMERIC(14,2) NOT NULL DEFAULT 0,
    remaining_amount NUMERIC(14,2) NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'unpaid',
    notes TEXT,
    created_by BIGINT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT uq_invoices_public_id UNIQUE (public_id),
    CONSTRAINT uq_invoices_invoice_number UNIQUE (invoice_number),
    CONSTRAINT fk_invoices_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE RESTRICT,
    CONSTRAINT fk_invoices_academic_year FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE RESTRICT,
    CONSTRAINT fk_invoices_semester FOREIGN KEY (semester_id) REFERENCES semesters(id) ON DELETE SET NULL,
    CONSTRAINT fk_invoices_generation_batch FOREIGN KEY (generation_batch_id) REFERENCES invoice_generation_batches(id) ON DELETE SET NULL,
    CONSTRAINT fk_invoices_created_by FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT chk_invoices_status CHECK (status IN ('draft', 'unpaid', 'partial', 'paid', 'overdue', 'cancelled')),
    CONSTRAINT chk_invoices_amounts CHECK (subtotal_amount >= 0 AND discount_amount >= 0 AND total_amount >= 0 AND paid_amount >= 0 AND remaining_amount >= 0)
);
CREATE INDEX idx_invoices_student_id ON invoices(student_id);
CREATE INDEX idx_invoices_academic_year_id ON invoices(academic_year_id);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoices_due_date ON invoices(due_date);

CREATE TABLE invoice_items (
    id BIGSERIAL PRIMARY KEY,
    invoice_id BIGINT NOT NULL,
    billing_type_id BIGINT,
    name VARCHAR(200) NOT NULL,
    item_type VARCHAR(30) NOT NULL DEFAULT 'charge',
    description TEXT,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_amount NUMERIC(14,2) NOT NULL DEFAULT 0,
    amount NUMERIC(14,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_invoice_items_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE,
    CONSTRAINT fk_invoice_items_billing_type FOREIGN KEY (billing_type_id) REFERENCES billing_types(id) ON DELETE SET NULL,
    CONSTRAINT chk_invoice_items_item_type CHECK (item_type IN ('charge', 'discount', 'waiver', 'scholarship', 'adjustment')),
    CONSTRAINT chk_invoice_items_quantity CHECK (quantity > 0)
);
CREATE INDEX idx_invoice_items_invoice_id ON invoice_items(invoice_id);

CREATE TABLE invoice_installments (
    id BIGSERIAL PRIMARY KEY,
    invoice_id BIGINT NOT NULL,
    installment_number INTEGER NOT NULL,
    due_date DATE NOT NULL,
    amount NUMERIC(14,2) NOT NULL DEFAULT 0,
    paid_amount NUMERIC(14,2) NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'unpaid',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_invoice_installments_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE,
    CONSTRAINT uq_invoice_installments_number UNIQUE (invoice_id, installment_number),
    CONSTRAINT chk_invoice_installments_status CHECK (status IN ('unpaid', 'partial', 'paid', 'overdue', 'cancelled')),
    CONSTRAINT chk_invoice_installments_amounts CHECK (amount >= 0 AND paid_amount >= 0)
);
CREATE INDEX idx_invoice_installments_invoice_id ON invoice_installments(invoice_id);
CREATE INDEX idx_invoice_installments_status ON invoice_installments(status);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS invoice_installments CASCADE;
DROP TABLE IF EXISTS invoice_items CASCADE;
DROP TABLE IF EXISTS invoices CASCADE;
DROP TABLE IF EXISTS invoice_generation_batches CASCADE;
DROP TABLE IF EXISTS billing_rules CASCADE;
DROP TABLE IF EXISTS billing_types CASCADE;
-- +goose StatementEnd
