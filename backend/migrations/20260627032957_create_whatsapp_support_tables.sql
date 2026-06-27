-- +goose Up
-- +goose StatementBegin

CREATE TABLE whatsapp_configurations (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL DEFAULT gen_random_uuid(),
    session_name VARCHAR(100) NOT NULL,
    display_name VARCHAR(150),
    phone_number VARCHAR(30),
    status VARCHAR(30) NOT NULL DEFAULT 'disconnected',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_connected_at TIMESTAMPTZ,
    last_disconnected_at TIMESTAMPTZ,
    last_error TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_whatsapp_configurations_public_id UNIQUE (public_id),
    CONSTRAINT uq_whatsapp_configurations_session_name UNIQUE (session_name),
    CONSTRAINT chk_whatsapp_configurations_status CHECK (status IN ('connected', 'disconnected', 'connecting', 'error'))
);

CREATE TABLE whatsapp_webhooks (
    id BIGSERIAL PRIMARY KEY,
    configuration_id BIGINT,
    session_name VARCHAR(100),
    event_type VARCHAR(100) NOT NULL,
    message_id VARCHAR(200),
    from_number VARCHAR(30),
    to_number VARCHAR(30),
    message_text TEXT,
    raw_payload JSONB NOT NULL,
    processing_status VARCHAR(30) NOT NULL DEFAULT 'pending',
    processed_at TIMESTAMPTZ,
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_whatsapp_webhooks_configuration FOREIGN KEY (configuration_id) REFERENCES whatsapp_configurations(id) ON DELETE SET NULL,
    CONSTRAINT chk_whatsapp_webhooks_processing_status CHECK (processing_status IN ('pending', 'processed', 'failed', 'ignored'))
);
CREATE INDEX idx_whatsapp_webhooks_configuration_id ON whatsapp_webhooks(configuration_id);
CREATE INDEX idx_whatsapp_webhooks_event_type ON whatsapp_webhooks(event_type);
CREATE INDEX idx_whatsapp_webhooks_processing_status ON whatsapp_webhooks(processing_status);

CREATE TABLE customer_support_tickets (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL DEFAULT gen_random_uuid(),
    ticket_number VARCHAR(100) NOT NULL,
    student_id BIGINT,
    guardian_id BIGINT,
    created_by BIGINT,
    assigned_to BIGINT,
    subject VARCHAR(200) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'open',
    priority VARCHAR(30) NOT NULL DEFAULT 'normal',
    source VARCHAR(30) NOT NULL DEFAULT 'web',
    closed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_customer_support_tickets_public_id UNIQUE (public_id),
    CONSTRAINT uq_customer_support_tickets_ticket_number UNIQUE (ticket_number),
    CONSTRAINT fk_customer_support_tickets_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE SET NULL,
    CONSTRAINT fk_customer_support_tickets_guardian FOREIGN KEY (guardian_id) REFERENCES guardians(id) ON DELETE SET NULL,
    CONSTRAINT fk_customer_support_tickets_created_by FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_customer_support_tickets_assigned_to FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT chk_customer_support_tickets_status CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
    CONSTRAINT chk_customer_support_tickets_priority CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    CONSTRAINT chk_customer_support_tickets_source CHECK (source IN ('web', 'whatsapp', 'system'))
);
CREATE INDEX idx_customer_support_tickets_student_id ON customer_support_tickets(student_id);
CREATE INDEX idx_customer_support_tickets_guardian_id ON customer_support_tickets(guardian_id);
CREATE INDEX idx_customer_support_tickets_status ON customer_support_tickets(status);

CREATE TABLE customer_support_messages (
    id BIGSERIAL PRIMARY KEY,
    ticket_id BIGINT NOT NULL,
    sender_user_id BIGINT,
    sender_type VARCHAR(30) NOT NULL,
    message_type VARCHAR(30) NOT NULL DEFAULT 'text',
    message TEXT NOT NULL,
    attachment_id BIGINT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_customer_support_messages_ticket FOREIGN KEY (ticket_id) REFERENCES customer_support_tickets(id) ON DELETE CASCADE,
    CONSTRAINT fk_customer_support_messages_sender_user FOREIGN KEY (sender_user_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT chk_customer_support_messages_sender_type CHECK (sender_type IN ('admin', 'guardian', 'student', 'system')),
    CONSTRAINT chk_customer_support_messages_message_type CHECK (message_type IN ('text', 'image', 'file', 'system'))
);
CREATE INDEX idx_customer_support_messages_ticket_id ON customer_support_messages(ticket_id);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS customer_support_messages CASCADE;
DROP TABLE IF EXISTS customer_support_tickets CASCADE;
DROP TABLE IF EXISTS whatsapp_webhooks CASCADE;
DROP TABLE IF EXISTS whatsapp_configurations CASCADE;
-- +goose StatementEnd
