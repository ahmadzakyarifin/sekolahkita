-- +goose Up
-- +goose StatementBegin

CREATE TABLE student_requests (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL DEFAULT gen_random_uuid(),
    request_number VARCHAR(100) NOT NULL,
    student_id BIGINT NOT NULL,
    guardian_id BIGINT,
    invoice_id BIGINT,
    requested_by BIGINT,
    request_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    requested_amount NUMERIC(14,2),
    approved_amount NUMERIC(14,2),
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    approved_by BIGINT,
    approved_at TIMESTAMPTZ,
    rejected_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_student_requests_public_id UNIQUE (public_id),
    CONSTRAINT uq_student_requests_request_number UNIQUE (request_number),
    CONSTRAINT fk_student_requests_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE RESTRICT,
    CONSTRAINT fk_student_requests_guardian FOREIGN KEY (guardian_id) REFERENCES guardians(id) ON DELETE SET NULL,
    CONSTRAINT fk_student_requests_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE SET NULL,
    CONSTRAINT fk_student_requests_requested_by FOREIGN KEY (requested_by) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_student_requests_approved_by FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT chk_student_requests_type CHECK (request_type IN ('financial_aid', 'scholarship', 'installment', 'waiver', 'refund', 'discount', 'invoice_adjustment', 'other')),
    CONSTRAINT chk_student_requests_status CHECK (status IN ('pending', 'reviewed', 'approved', 'rejected', 'cancelled'))
);
CREATE INDEX idx_student_requests_student_id ON student_requests(student_id);
CREATE INDEX idx_student_requests_guardian_id ON student_requests(guardian_id);
CREATE INDEX idx_student_requests_invoice_id ON student_requests(invoice_id);
CREATE INDEX idx_student_requests_status ON student_requests(status);
CREATE INDEX idx_student_requests_request_type ON student_requests(request_type);

CREATE TABLE approval_actions (
    id BIGSERIAL PRIMARY KEY,
    student_request_id BIGINT NOT NULL,
    actor_id BIGINT,
    action VARCHAR(30) NOT NULL,
    note TEXT,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_approval_actions_student_request FOREIGN KEY (student_request_id) REFERENCES student_requests(id) ON DELETE CASCADE,
    CONSTRAINT fk_approval_actions_actor FOREIGN KEY (actor_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT chk_approval_actions_action CHECK (action IN ('submitted', 'reviewed', 'approved', 'rejected', 'cancelled', 'revised'))
);
CREATE INDEX idx_approval_actions_student_request_id ON approval_actions(student_request_id);
CREATE INDEX idx_approval_actions_actor_id ON approval_actions(actor_id);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS approval_actions CASCADE;
DROP TABLE IF EXISTS student_requests CASCADE;
-- +goose StatementEnd
