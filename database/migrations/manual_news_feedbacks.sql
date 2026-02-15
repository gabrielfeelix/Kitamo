-- Criar tabela de feedbacks de novidades
CREATE TABLE IF NOT EXISTS news_feedbacks (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    news_item_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    feedback_text TEXT NOT NULL,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    
    INDEX idx_news_item (news_item_id),
    INDEX idx_user (user_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Atualizar tabela de reações para garantir unicidade por usuário
-- Se a tabela já existir, vamos apenas adicionar o índice único
ALTER TABLE news_reactions 
ADD UNIQUE KEY unique_user_news_reaction (news_item_id, user_id);
