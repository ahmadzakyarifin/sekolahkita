-- +goose Up
-- +goose StatementBegin

CREATE TABLE activity_logs (
    id BIGSERIAL PRIMARY KEY,
    public_id UUID NOT NULL DEFAULT gen_random_uuid(),
    actor_id BIGINT,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100),
    entity_id BIGINT,
    description TEXT,
    ip_address INET,
    user_agent TEXT,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_activity_logs_public_id UNIQUE (public_id),
    CONSTRAINT fk_activity_logs_actor FOREIGN KEY (actor_id) REFERENCES users(id) ON DELETE SET NULL
);
CREATE INDEX idx_activity_logs_actor_id ON activity_logs(actor_id);
CREATE INDEX idx_activity_logs_action ON activity_logs(action);
CREATE INDEX idx_activity_logs_entity ON activity_logs(entity_type, entity_id);
CREATE INDEX idx_activity_logs_created_at ON activity_logs(created_at);

CREATE TABLE idempotency_keys (
    id BIGSERIAL PRIMARY KEY,
    key VARCHAR(200) NOT NULL,
    user_id BIGINT,
    request_method VARCHAR(20) NOT NULL,
    request_path TEXT NOT NULL,
    request_hash TEXT,
    response_status INTEGER,
    response_body JSONB,
    status VARCHAR(30) NOT NULL DEFAULT 'processing',
    locked_until TIMESTAMPTZ,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_idempotency_keys_key UNIQUE (key),
    CONSTRAINT fk_idempotency_keys_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT chk_idempotency_keys_status CHECK (status IN ('processing', 'completed', 'failed'))
);
CREATE INDEX idx_idempotency_keys_user_id ON idempotency_keys(user_id);
CREATE INDEX idx_idempotency_keys_expires_at ON idempotency_keys(expires_at);
CREATE INDEX idx_idempotency_keys_status ON idempotency_keys(status);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS idempotency_keys CASCADE;
DROP TABLE IF EXISTS activity_logs CASCADE;
-- +goose StatementEnd
