-- SQL para criar tabela de feedbacks (SQLite)
-- Execute este SQL caso a migração não tenha sido executada automaticamente

CREATE TABLE IF NOT EXISTS news_feedbacks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    news_item_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    feedback_text TEXT NOT NULL,
    created_at DATETIME,
    updated_at DATETIME
);

CREATE INDEX IF NOT EXISTS idx_news_feedbacks_news_item ON news_feedbacks(news_item_id);
CREATE INDEX IF NOT EXISTS idx_news_feedbacks_user ON news_feedbacks(user_id);
CREATE INDEX IF NOT EXISTS idx_news_feedbacks_created_at ON news_feedbacks(created_at);

-- Garantir unicidade de reações (cada usuário só pode ter uma reação por novidade)
-- Primeiro, remover duplicatas se existirem
DELETE FROM news_reactions 
WHERE id NOT IN (
    SELECT MIN(id) 
    FROM news_reactions 
    GROUP BY news_item_id, user_id
);

-- Adicionar índice único
CREATE UNIQUE INDEX IF NOT EXISTS unique_user_news_reaction 
ON news_reactions(news_item_id, user_id);
