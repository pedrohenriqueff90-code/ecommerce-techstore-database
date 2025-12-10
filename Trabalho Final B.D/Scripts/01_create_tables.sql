-- ============================================
-- SISTEMA E-COMMERCE - TECHSTORE BRASIL
-- Script de Criação de Tabelas
-- ============================================

-- Remover tabelas caso existam (para recriar)
DROP TABLE IF EXISTS avaliacoes CASCADE;
DROP TABLE IF EXISTS itens_pedido CASCADE;
DROP TABLE IF EXISTS pedidos CASCADE;
DROP TABLE IF EXISTS produtos CASCADE;
DROP TABLE IF EXISTS fornecedores CASCADE;
DROP TABLE IF EXISTS categorias CASCADE;
DROP TABLE IF EXISTS enderecos CASCADE;
DROP TABLE IF EXISTS emails_clientes CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;

-- ============================================
-- 1. TABELA: CLIENTES
-- ============================================
CREATE TABLE clientes (
    id_cliente SERIAL PRIMARY KEY,
    nome_completo VARCHAR(200) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    data_nascimento DATE NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE,
    CONSTRAINT chk_cpf_formato CHECK (cpf ~ '^\d{3}\.\d{3}\.\d{3}-\d{2}$'),
    CONSTRAINT chk_data_nascimento CHECK (data_nascimento <= CURRENT_DATE)
);

COMMENT ON TABLE clientes IS 'Cadastro de clientes da loja';
COMMENT ON COLUMN clientes.cpf IS 'CPF no formato XXX.XXX.XXX-XX';

-- ============================================
-- 2. TABELA: EMAILS_CLIENTES (Atributo Multivalorado)
-- ============================================
CREATE TABLE emails_clientes (
    id_email SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    email VARCHAR(150) NOT NULL,
    principal BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_emails_cliente FOREIGN KEY (id_cliente) 
        REFERENCES clientes(id_cliente) ON DELETE CASCADE,
    CONSTRAINT chk_email_formato CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

COMMENT ON TABLE emails_clientes IS 'Emails dos clientes (atributo multivalorado)';

-- ============================================
-- 3. TABELA: ENDERECOS (Atributo Composto)
-- ============================================
CREATE TABLE enderecos (
    id_endereco SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    rua VARCHAR(200) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    complemento VARCHAR(100),
    bairro VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado CHAR(2) NOT NULL,
    cep VARCHAR(9) NOT NULL,
    tipo_endereco VARCHAR(20) DEFAULT 'RESIDENCIAL',
    CONSTRAINT fk_endereco_cliente FOREIGN KEY (id_cliente) 
        REFERENCES clientes(id_cliente) ON DELETE CASCADE,
    CONSTRAINT chk_tipo_endereco CHECK (tipo_endereco IN ('RESIDENCIAL', 'COMERCIAL', 'OUTRO')),
    CONSTRAINT chk_cep_formato CHECK (cep ~ '^\d{5}-\d{3}$'),
    CONSTRAINT chk_estado CHECK (LENGTH(estado) = 2)
);

COMMENT ON TABLE enderecos IS 'Endereços dos clientes (atributo composto decomposto)';
COMMENT ON COLUMN enderecos.cep IS 'CEP no formato XXXXX-XXX';

-- ============================================
-- 4. TABELA: CATEGORIAS
-- ============================================
CREATE TABLE categorias (
    id_categoria SERIAL PRIMARY KEY,
    nome_categoria VARCHAR(100) UNIQUE NOT NULL,
    descricao TEXT,
    ativa BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE categorias IS 'Categorias de produtos';

-- ============================================
-- 5. TABELA: FORNECEDORES
-- ============================================
CREATE TABLE fornecedores (
    id_fornecedor SERIAL PRIMARY KEY,
    nome_empresa VARCHAR(200) NOT NULL,
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    telefone VARCHAR(15),
    email VARCHAR(150),
    ativo BOOLEAN DEFAULT TRUE,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_cnpj_formato CHECK (cnpj ~ '^\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}$')
);

COMMENT ON TABLE fornecedores IS 'Fornecedores de produtos';
COMMENT ON COLUMN fornecedores.cnpj IS 'CNPJ no formato XX.XXX.XXX/XXXX-XX';

-- ============================================
-- 6. TABELA: PRODUTOS
-- ============================================
CREATE TABLE produtos (
    id_produto SERIAL PRIMARY KEY,
    id_categoria INTEGER NOT NULL,
    id_fornecedor INTEGER NOT NULL,
    nome_produto VARCHAR(200) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10, 2) NOT NULL,
    quantidade_estoque INTEGER DEFAULT 0,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_produto_categoria FOREIGN KEY (id_categoria) 
        REFERENCES categorias(id_categoria),
    CONSTRAINT fk_produto_fornecedor FOREIGN KEY (id_fornecedor) 
        REFERENCES fornecedores(id_fornecedor),
    CONSTRAINT chk_preco_positivo CHECK (preco > 0),
    CONSTRAINT chk_estoque_nao_negativo CHECK (quantidade_estoque >= 0)
);

COMMENT ON TABLE produtos IS 'Produtos disponíveis para venda';

-- ============================================
-- 7. TABELA: PEDIDOS
-- ============================================
CREATE TABLE pedidos (
    id_pedido SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    id_endereco_entrega INTEGER NOT NULL,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'PENDENTE',
    forma_pagamento VARCHAR(30) NOT NULL,
    observacoes TEXT,
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) 
        REFERENCES clientes(id_cliente),
    CONSTRAINT fk_pedido_endereco FOREIGN KEY (id_endereco_entrega) 
        REFERENCES enderecos(id_endereco),
    CONSTRAINT chk_status CHECK (status IN ('PENDENTE', 'PROCESSANDO', 'ENVIADO', 'ENTREGUE', 'CANCELADO')),
    CONSTRAINT chk_forma_pagamento CHECK (forma_pagamento IN ('CARTAO_CREDITO', 'CARTAO_DEBITO', 'PIX', 'BOLETO'))
);

COMMENT ON TABLE pedidos IS 'Pedidos realizados pelos clientes';

-- ============================================
-- 8. TABELA: ITENS_PEDIDO (Relacionamento N:N)
-- ============================================
CREATE TABLE itens_pedido (
    id_item SERIAL PRIMARY KEY,
    id_pedido INTEGER NOT NULL,
    id_produto INTEGER NOT NULL,
    quantidade INTEGER NOT NULL,
    preco_unitario DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_item_pedido FOREIGN KEY (id_pedido) 
        REFERENCES pedidos(id_pedido) ON DELETE CASCADE,
    CONSTRAINT fk_item_produto FOREIGN KEY (id_produto) 
        REFERENCES produtos(id_produto),
    CONSTRAINT chk_quantidade_positiva CHECK (quantidade > 0),
    CONSTRAINT chk_preco_unitario_positivo CHECK (preco_unitario > 0)
);

COMMENT ON TABLE itens_pedido IS 'Itens de cada pedido (tabela associativa N:N)';

-- ============================================
-- 9. TABELA: AVALIACOES
-- ============================================
CREATE TABLE avaliacoes (
    id_avaliacao SERIAL PRIMARY KEY,
    id_produto INTEGER NOT NULL,
    id_cliente INTEGER NOT NULL,
    nota INTEGER NOT NULL,
    comentario TEXT,
    data_avaliacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_avaliacao_produto FOREIGN KEY (id_produto) 
        REFERENCES produtos(id_produto) ON DELETE CASCADE,
    CONSTRAINT fk_avaliacao_cliente FOREIGN KEY (id_cliente) 
        REFERENCES clientes(id_cliente) ON DELETE CASCADE,
    CONSTRAINT chk_nota_valida CHECK (nota BETWEEN 1 AND 5),
    CONSTRAINT uk_avaliacao_cliente_produto UNIQUE (id_produto, id_cliente)
);

COMMENT ON TABLE avaliacoes IS 'Avaliações de produtos pelos clientes';
COMMENT ON COLUMN avaliacoes.nota IS 'Nota de 1 a 5 estrelas';

-- ============================================
-- ÍNDICES PARA OTIMIZAÇÃO DE CONSULTAS
-- ============================================

-- Índices em chaves estrangeiras
CREATE INDEX idx_emails_cliente ON emails_clientes(id_cliente);
CREATE INDEX idx_enderecos_cliente ON enderecos(id_cliente);
CREATE INDEX idx_produtos_categoria ON produtos(id_categoria);
CREATE INDEX idx_produtos_fornecedor ON produtos(id_fornecedor);
CREATE INDEX idx_pedidos_cliente ON pedidos(id_cliente);
CREATE INDEX idx_pedidos_endereco ON pedidos(id_endereco_entrega);
CREATE INDEX idx_itens_pedido ON itens_pedido(id_pedido);
CREATE INDEX idx_itens_produto ON itens_pedido(id_produto);
CREATE INDEX idx_avaliacoes_produto ON avaliacoes(id_produto);
CREATE INDEX idx_avaliacoes_cliente ON avaliacoes(id_cliente);

-- Índices em campos de busca frequente
CREATE INDEX idx_clientes_cpf ON clientes(cpf);
CREATE INDEX idx_clientes_nome ON clientes(nome_completo);
CREATE INDEX idx_fornecedores_cnpj ON fornecedores(cnpj);
CREATE INDEX idx_produtos_nome ON produtos(nome_produto);
CREATE INDEX idx_pedidos_data ON pedidos(data_pedido DESC);
CREATE INDEX idx_pedidos_status ON pedidos(status);

-- ============================================
-- VIEWS PARA ATRIBUTOS DERIVADOS
-- ============================================

-- View: Clientes com idade calculada
CREATE OR REPLACE VIEW vw_clientes_com_idade AS
SELECT 
    c.*,
    DATE_PART('year', AGE(CURRENT_DATE, c.data_nascimento))::INTEGER AS idade
FROM clientes c;

-- View: Pedidos com valor total
CREATE OR REPLACE VIEW vw_pedidos_com_total AS
SELECT 
    p.*,
    COALESCE(SUM(ip.quantidade * ip.preco_unitario), 0) AS valor_total
FROM pedidos p
LEFT JOIN itens_pedido ip ON p.id_pedido = ip.id_pedido
GROUP BY p.id_pedido;

-- View: Itens de pedido com subtotal
CREATE OR REPLACE VIEW vw_itens_com_subtotal AS
SELECT 
    ip.*,
    (ip.quantidade * ip.preco_unitario) AS subtotal
FROM itens_pedido ip;

-- View: Produtos com média de avaliações
CREATE OR REPLACE VIEW vw_produtos_com_avaliacoes AS
SELECT 
    p.*,
    COALESCE(ROUND(AVG(a.nota), 2), 0) AS media_avaliacoes,
    COUNT(a.id_avaliacao) AS total_avaliacoes
FROM produtos p
LEFT JOIN avaliacoes a ON p.id_produto = a.id_produto
GROUP BY p.id_produto;

-- ============================================
-- FIM DO SCRIPT
-- ============================================

SELECT 'Tabelas criadas com sucesso!' AS mensagem;