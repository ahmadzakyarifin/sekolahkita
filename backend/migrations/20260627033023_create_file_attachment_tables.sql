-- +goose Up
-- +goose StatementBegin

CREATE TABLE file_attachments (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL DEFAULT gen_random_uuid(),
    uploaded_by BIGINT,
    attachable_type VARCHAR(100),
    attachable_id BIGINT,
    original_name VARCHAR(255) NOT NULL,
    stored_name VARCHAR(255) NOT NULL,
    file_path TEXT NOT NULL,
    mime_type VARCHAR(150),
    file_size BIGINT,
    disk VARCHAR(50) NOT NULL DEFAULT 'local',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_file_attachments_public_id UNIQUE (public_id),
    CONSTRAINT fk_file_attachments_uploaded_by FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE SET NULL
);
CREATE INDEX idx_file_attachments_uploaded_by ON file_attachments(uploaded_by);
CREATE INDEX idx_file_attachments_attachable ON file_attachments(attachable_type, attachable_id);

-- Tambahkan FK attachment_id di customer_support_messages setelah file_attachments dibuat
ALTER TABLE customer_support_messages
ADD CONSTRAINT fk_customer_support_messages_attachment
FOREIGN KEY (attachment_id) REFERENCES file_attachments(id)
ON DELETE SET NULL;

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE customer_support_messages DROP CONSTRAINT IF EXISTS fk_customer_support_messages_attachment;
DROP TABLE IF EXISTS file_attachments CASCADE;
-- +goose StatementEnd
