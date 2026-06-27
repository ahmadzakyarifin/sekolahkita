-- +goose Up
-- +goose StatementBegin

CREATE TABLE payment_methods (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL,
    name VARCHAR(150) NOT NULL,
    provider VARCHAR(100),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_payment_methods_public_id UNIQUE (public_id),
    CONSTRAINT uq_payment_methods_code UNIQUE (code)
);

CREATE TABLE payments (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL DEFAULT gen_random_uuid(),
    payment_number VARCHAR(100) NOT NULL,
    student_id BIGINT NOT NULL,
    guardian_id BIGINT,
    payment_method_id BIGINT NOT NULL,
    amount NUMERIC(14,2) NOT NULL,
    payment_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    reference_number VARCHAR(150),
    notes TEXT,
    received_by BIGINT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT uq_payments_public_id UNIQUE (public_id),
    CONSTRAINT uq_payments_payment_number UNIQUE (payment_number),
    CONSTRAINT fk_payments_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE RESTRICT,
    CONSTRAINT fk_payments_guardian FOREIGN KEY (guardian_id) REFERENCES guardians(id) ON DELETE SET NULL,
    CONSTRAINT fk_payments_payment_method FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id) ON DELETE RESTRICT,
    CONSTRAINT fk_payments_received_by FOREIGN KEY (received_by) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT chk_payments_status CHECK (status IN ('pending', 'success', 'failed', 'cancelled', 'refunded')),
    CONSTRAINT chk_payments_amount CHECK (amount >= 0)
);
CREATE INDEX idx_payments_student_id ON payments(student_id);
CREATE INDEX idx_payments_guardian_id ON payments(guardian_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_payment_date ON payments(payment_date);

CREATE TABLE payment_allocations (
    id BIGSERIAL PRIMARY KEY,
    payment_id BIGINT NOT NULL,
    invoice_id BIGINT NOT NULL,
    invoice_installment_id BIGINT,
    amount NUMERIC(14,2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_payment_allocations_payment FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE,
    CONSTRAINT fk_payment_allocations_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE RESTRICT,
    CONSTRAINT fk_payment_allocations_installment FOREIGN KEY (invoice_installment_id) REFERENCES invoice_installments(id) ON DELETE SET NULL,
    CONSTRAINT chk_payment_allocations_amount CHECK (amount > 0)
);
CREATE INDEX idx_payment_allocations_payment_id ON payment_allocations(payment_id);
CREATE INDEX idx_payment_allocations_invoice_id ON payment_allocations(invoice_id);

CREATE TABLE payment_gateway_transactions (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL DEFAULT gen_random_uuid(),
    payment_id BIGINT,
    student_id BIGINT NOT NULL,
    gateway VARCHAR(100) NOT NULL DEFAULT 'midtrans',
    order_id VARCHAR(150) NOT NULL,
    transaction_id VARCHAR(150),
    payment_type VARCHAR(100),
    gross_amount NUMERIC(14,2) NOT NULL DEFAULT 0,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    redirect_url TEXT,
    snap_token TEXT,
    raw_response JSONB,
    expired_at TIMESTAMPTZ,
    paid_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_payment_gateway_transactions_public_id UNIQUE (public_id),
    CONSTRAINT uq_payment_gateway_transactions_order_id UNIQUE (order_id),
    CONSTRAINT fk_payment_gateway_transactions_payment FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE SET NULL,
    CONSTRAINT fk_payment_gateway_transactions_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE RESTRICT,
    CONSTRAINT chk_payment_gateway_transactions_status CHECK (status IN ('pending', 'challenge', 'success', 'settlement', 'capture', 'deny', 'expire', 'cancel', 'failure', 'refund'))
);
CREATE INDEX idx_payment_gateway_transactions_student_id ON payment_gateway_transactions(student_id);
CREATE INDEX idx_payment_gateway_transactions_payment_id ON payment_gateway_transactions(payment_id);
CREATE INDEX idx_payment_gateway_transactions_status ON payment_gateway_transactions(status);

CREATE TABLE payment_webhooks (
    id BIGSERIAL PRIMARY KEY,
    gateway_transaction_id BIGINT,
    gateway VARCHAR(100) NOT NULL DEFAULT 'midtrans',
    order_id VARCHAR(150),
    external_event_id VARCHAR(150),
    event_type VARCHAR(100),
    signature_key TEXT,
    raw_payload JSONB NOT NULL,
    processing_status VARCHAR(30) NOT NULL DEFAULT 'pending',
    processed_at TIMESTAMPTZ,
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_payment_webhooks_gateway_transaction FOREIGN KEY (gateway_transaction_id) REFERENCES payment_gateway_transactions(id) ON DELETE SET NULL,
    CONSTRAINT uq_payment_webhooks_external_event_id UNIQUE (external_event_id),
    CONSTRAINT chk_payment_webhooks_processing_status CHECK (processing_status IN ('pending', 'processed', 'failed', 'ignored'))
);
CREATE INDEX idx_payment_webhooks_gateway_transaction_id ON payment_webhooks(gateway_transaction_id);
CREATE INDEX idx_payment_webhooks_order_id ON payment_webhooks(order_id);
CREATE INDEX idx_payment_webhooks_processing_status ON payment_webhooks(processing_status);

CREATE TABLE student_balances (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT NOT NULL,
    balance NUMERIC(14,2) NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_student_balances_student UNIQUE (student_id),
    CONSTRAINT fk_student_balances_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT chk_student_balances_balance CHECK (balance >= 0)
);

CREATE TABLE student_balance_mutations (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT NOT NULL,
    payment_id BIGINT,
    invoice_id BIGINT,
    mutation_type VARCHAR(50) NOT NULL,
    direction VARCHAR(10) NOT NULL,
    amount NUMERIC(14,2) NOT NULL,
    balance_before NUMERIC(14,2) NOT NULL,
    balance_after NUMERIC(14,2) NOT NULL,
    description TEXT,
    created_by BIGINT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_student_balance_mutations_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE RESTRICT,
    CONSTRAINT fk_student_balance_mutations_payment FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE SET NULL,
    CONSTRAINT fk_student_balance_mutations_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE SET NULL,
    CONSTRAINT fk_student_balance_mutations_created_by FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT chk_student_balance_mutations_direction CHECK (direction IN ('in', 'out')),
    CONSTRAINT chk_student_balance_mutations_amount CHECK (amount > 0)
);
CREATE INDEX idx_student_balance_mutations_student_id ON student_balance_mutations(student_id);
CREATE INDEX idx_student_balance_mutations_payment_id ON student_balance_mutations(payment_id);
CREATE INDEX idx_student_balance_mutations_invoice_id ON student_balance_mutations(invoice_id);
CREATE INDEX idx_student_balance_mutations_created_at ON student_balance_mutations(created_at);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS student_balance_mutations CASCADE;
DROP TABLE IF EXISTS student_balances CASCADE;
DROP TABLE IF EXISTS payment_webhooks CASCADE;
DROP TABLE IF EXISTS payment_gateway_transactions CASCADE;
DROP TABLE IF EXISTS payment_allocations CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS payment_methods CASCADE;
-- +goose StatementEnd
