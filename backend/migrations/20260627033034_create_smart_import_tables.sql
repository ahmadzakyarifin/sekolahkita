-- +goose Up
-- +goose StatementBegin

CREATE TABLE import_batches (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL DEFAULT gen_random_uuid(),
    file_attachment_id BIGINT,
    import_type VARCHAR(50) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'uploaded',
    total_rows INTEGER NOT NULL DEFAULT 0,
    success_rows INTEGER NOT NULL DEFAULT 0,
    failed_rows INTEGER NOT NULL DEFAULT 0,
    uploaded_by BIGINT,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_import_batches_public_id UNIQUE (public_id),
    CONSTRAINT fk_import_batches_file_attachment FOREIGN KEY (file_attachment_id) REFERENCES file_attachments(id) ON DELETE SET NULL,
    CONSTRAINT fk_import_batches_uploaded_by FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT chk_import_batches_type CHECK (import_type IN ('students', 'guardians', 'classes', 'invoices', 'payments', 'mixed')),
    CONSTRAINT chk_import_batches_status CHECK (status IN ('uploaded', 'validating', 'ready', 'importing', 'completed', 'failed', 'cancelled'))
);
CREATE INDEX idx_import_batches_file_attachment_id ON import_batches(file_attachment_id);
CREATE INDEX idx_import_batches_import_type ON import_batches(import_type);
CREATE INDEX idx_import_batches_status ON import_batches(status);

CREATE TABLE import_rows (
    id BIGSERIAL PRIMARY KEY,
    import_batch_id BIGINT NOT NULL,
    row_number INTEGER NOT NULL,
    raw_data JSONB NOT NULL,
    mapped_data JSONB,
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    error_messages JSONB,
    target_type VARCHAR(100),
    target_id BIGINT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_import_rows_import_batch FOREIGN KEY (import_batch_id) REFERENCES import_batches(id) ON DELETE CASCADE,
    CONSTRAINT uq_import_rows_batch_row UNIQUE (import_batch_id, row_number),
    CONSTRAINT chk_import_rows_status CHECK (status IN ('pending', 'valid', 'invalid', 'imported', 'failed', 'skipped'))
);
CREATE INDEX idx_import_rows_import_batch_id ON import_rows(import_batch_id);
CREATE INDEX idx_import_rows_status ON import_rows(status);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS import_rows CASCADE;
DROP TABLE IF EXISTS import_batches CASCADE;
-- +goose StatementEnd
