-- +goose Up
-- +goose StatementBegin

CREATE TABLE notification_templates (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL DEFAULT gen_random_uuid(),
    code VARCHAR(100) NOT NULL,
    channel VARCHAR(30) NOT NULL,
    title VARCHAR(200),
    body_template TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_notification_templates_public_id UNIQUE (public_id),
    CONSTRAINT uq_notification_templates_code_channel UNIQUE (code, channel),
    CONSTRAINT chk_notification_templates_channel CHECK (channel IN ('whatsapp', 'email', 'system'))
);

CREATE TABLE notifications (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL DEFAULT gen_random_uuid(),
    template_id BIGINT,
    student_id BIGINT,
    guardian_id BIGINT,
    recipient_user_id BIGINT,
    channel VARCHAR(30) NOT NULL,
    destination VARCHAR(200) NOT NULL,
    subject VARCHAR(200),
    message TEXT NOT NULL,
    payload JSONB,
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    error_message TEXT,
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_notifications_public_id UNIQUE (public_id),
    CONSTRAINT fk_notifications_template FOREIGN KEY (template_id) REFERENCES notification_templates(id) ON DELETE SET NULL,
    CONSTRAINT fk_notifications_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE SET NULL,
    CONSTRAINT fk_notifications_guardian FOREIGN KEY (guardian_id) REFERENCES guardians(id) ON DELETE SET NULL,
    CONSTRAINT fk_notifications_recipient_user FOREIGN KEY (recipient_user_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT chk_notifications_channel CHECK (channel IN ('whatsapp', 'email', 'system')),
    CONSTRAINT chk_notifications_status CHECK (status IN ('pending', 'sent', 'failed', 'cancelled'))
);
CREATE INDEX idx_notifications_student_id ON notifications(student_id);
CREATE INDEX idx_notifications_guardian_id ON notifications(guardian_id);
CREATE INDEX idx_notifications_recipient_user_id ON notifications(recipient_user_id);
CREATE INDEX idx_notifications_status ON notifications(status);
CREATE INDEX idx_notifications_channel ON notifications(channel);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS notification_templates CASCADE;
-- +goose StatementEnd
