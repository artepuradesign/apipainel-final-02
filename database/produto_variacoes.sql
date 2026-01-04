-- =====================================================
-- TABELA: produto_variacoes
-- Variações de cor e capacidade para cada produto
-- =====================================================

CREATE TABLE IF NOT EXISTS produto_variacoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produto_id INT NOT NULL,
    cor VARCHAR(50),
    cor_codigo VARCHAR(7), -- Código hexadecimal da cor
    capacidade VARCHAR(20),
    estoque INT DEFAULT 0,
    preco DECIMAL(10,2), -- Preço específico da variação (se diferente)
    ativo TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_variacoes_produto ON produto_variacoes(produto_id);

-- =====================================================
-- DADOS DE EXEMPLO: Variações para iPhone 13
-- =====================================================
INSERT INTO produto_variacoes (produto_id, cor, cor_codigo, capacidade, estoque, preco, ativo) VALUES
-- iPhone 13 128GB (produto_id = 3)
(3, 'Rosa', '#FADADD', '128GB', 5, 2999.00, 1),
(3, 'Azul', '#87CEEB', '128GB', 3, 2999.00, 1),
(3, 'Preto', '#1C1C1C', '128GB', 0, 2999.00, 1),
(3, 'Branco', '#F5F5F5', '128GB', 0, 2999.00, 1),
(3, 'Verde', '#98D8AA', '128GB', 2, 2999.00, 1),
(3, 'Vermelho', '#DC143C', '128GB', 0, 2999.00, 1),
(3, 'Rosa', '#FADADD', '256GB', 2, 3299.00, 1),
(3, 'Azul', '#87CEEB', '256GB', 1, 3299.00, 1),
(3, 'Preto', '#1C1C1C', '256GB', 0, 3299.00, 1),
(3, 'Rosa', '#FADADD', '512GB', 0, 3799.00, 1),

-- iPhone 15 Pro (produto_id = 1)
(1, 'Titânio Natural', '#D4D4D4', '256GB', 3, 6499.00, 1),
(1, 'Titânio Azul', '#5A6E7F', '256GB', 2, 6499.00, 1),
(1, 'Titânio Preto', '#1C1C1C', '256GB', 1, 6499.00, 1),
(1, 'Titânio Branco', '#F5F5F5', '256GB', 0, 6499.00, 1),
(1, 'Titânio Natural', '#D4D4D4', '512GB', 1, 7499.00, 1),
(1, 'Titânio Natural', '#D4D4D4', '1TB', 0, 8499.00, 1);
