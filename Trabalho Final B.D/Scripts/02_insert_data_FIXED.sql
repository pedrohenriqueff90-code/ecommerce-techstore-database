-- ============================================
-- SISTEMA E-COMMERCE - TECHSTORE BRASIL
-- Script de Inserção de Dados COM COMMIT
-- ============================================

BEGIN;

-- ============================================
-- 1. INSERIR CLIENTES (500 registros)
-- ============================================
INSERT INTO clientes (nome_completo, cpf, data_nascimento, data_cadastro, ativo)
SELECT 
    CASE (i % 10)
        WHEN 0 THEN 'João Silva' || i
        WHEN 1 THEN 'Maria Santos' || i
        WHEN 2 THEN 'Pedro Oliveira' || i
        WHEN 3 THEN 'Ana Costa' || i
        WHEN 4 THEN 'Carlos Souza' || i
        WHEN 5 THEN 'Juliana Lima' || i
        WHEN 6 THEN 'Lucas Ferreira' || i
        WHEN 7 THEN 'Patricia Alves' || i
        WHEN 8 THEN 'Rafael Pereira' || i
        ELSE 'Fernanda Rodrigues' || i
    END,
    LPAD(((i * 123) % 1000)::TEXT, 3, '0') || '.' || 
    LPAD(((i * 456) % 1000)::TEXT, 3, '0') || '.' || 
    LPAD(((i * 789) % 1000)::TEXT, 3, '0') || '-' || 
    LPAD(((i * 12) % 100)::TEXT, 2, '0'),
    CURRENT_DATE - ((i * 365) % 18250) * INTERVAL '1 day',
    CURRENT_TIMESTAMP - (i * INTERVAL '1 day'),
    (i % 20) != 0
FROM generate_series(1, 500) AS i;

-- ============================================
-- 2. INSERIR EMAILS_CLIENTES (1000 registros)
-- ============================================
INSERT INTO emails_clientes (id_cliente, email, principal)
SELECT 
    i,
    'cliente' || i || '@email.com',
    TRUE
FROM generate_series(1, 500) AS i;

INSERT INTO emails_clientes (id_cliente, email, principal)
SELECT 
    i,
    'cliente' || i || '.secundario@gmail.com',
    FALSE
FROM generate_series(1, 500) AS i;

-- ============================================
-- 3. INSERIR ENDERECOS (750 registros)
-- ============================================
INSERT INTO enderecos (id_cliente, rua, numero, complemento, bairro, cidade, estado, cep, tipo_endereco)
SELECT 
    ((i - 1) % 500) + 1,
    CASE ((i - 1) % 10)
        WHEN 0 THEN 'Rua das Flores'
        WHEN 1 THEN 'Avenida Paulista'
        WHEN 2 THEN 'Rua Augusta'
        WHEN 3 THEN 'Alameda Santos'
        WHEN 4 THEN 'Rua Consolação'
        WHEN 5 THEN 'Avenida Rebouças'
        WHEN 6 THEN 'Rua da Mooca'
        WHEN 7 THEN 'Avenida Ipiranga'
        WHEN 8 THEN 'Rua Vergueiro'
        ELSE 'Avenida Faria Lima'
    END,
    ((i * 7) % 9999)::TEXT,
    CASE WHEN i % 3 = 0 THEN 'Apto ' || ((i % 500) + 1) ELSE NULL END,
    CASE ((i - 1) % 8)
        WHEN 0 THEN 'Centro'
        WHEN 1 THEN 'Jardins'
        WHEN 2 THEN 'Vila Mariana'
        WHEN 3 THEN 'Moema'
        WHEN 4 THEN 'Pinheiros'
        WHEN 5 THEN 'Tatuapé'
        WHEN 6 THEN 'Santana'
        ELSE 'Mooca'
    END,
    CASE ((i - 1) % 5)
        WHEN 0 THEN 'São Paulo'
        WHEN 1 THEN 'Rio de Janeiro'
        WHEN 2 THEN 'Belo Horizonte'
        WHEN 3 THEN 'Curitiba'
        ELSE 'Porto Alegre'
    END,
    CASE ((i - 1) % 5)
        WHEN 0 THEN 'SP'
        WHEN 1 THEN 'RJ'
        WHEN 2 THEN 'MG'
        WHEN 3 THEN 'PR'
        ELSE 'RS'
    END,
    LPAD(((i * 123) % 100000)::TEXT, 5, '0') || '-' || LPAD(((i * 7) % 1000)::TEXT, 3, '0'),
    CASE 
        WHEN i % 3 = 0 THEN 'COMERCIAL'
        WHEN i % 5 = 0 THEN 'OUTRO'
        ELSE 'RESIDENCIAL'
    END
FROM generate_series(1, 750) AS i;

-- ============================================
-- 4. INSERIR CATEGORIAS (20 registros)
-- ============================================
INSERT INTO categorias (nome_categoria, descricao, ativa) VALUES
('Smartphones', 'Celulares e smartphones de diversas marcas', TRUE),
('Notebooks', 'Notebooks e laptops para trabalho e entretenimento', TRUE),
('Tablets', 'Tablets e iPads', TRUE),
('Monitores', 'Monitores e displays', TRUE),
('Teclados', 'Teclados mecânicos e de membrana', TRUE),
('Mouses', 'Mouses com e sem fio', TRUE),
('Fones de Ouvido', 'Fones de ouvido e headsets', TRUE),
('Webcams', 'Câmeras para streaming e videoconferência', TRUE),
('Impressoras', 'Impressoras e multifuncionais', TRUE),
('Scanners', 'Scanners de documentos', TRUE),
('Roteadores', 'Roteadores e equipamentos de rede', TRUE),
('Pen Drives', 'Pen drives e cartões de memória', TRUE),
('HDs Externos', 'HDs externos e SSDs portáteis', TRUE),
('Cabos', 'Cabos USB, HDMI e outros', TRUE),
('Carregadores', 'Carregadores e fontes de alimentação', TRUE),
('Cases', 'Cases e capas protetoras', TRUE),
('Suportes', 'Suportes para notebook e monitor', TRUE),
('Mousepads', 'Mousepads e superfícies para mouse', TRUE),
('Webcams 4K', 'Webcams de alta resolução', TRUE),
('Acessórios Gamer', 'Acessórios para games', TRUE);

-- ============================================
-- 5. INSERIR FORNECEDORES (50 registros)
-- ============================================
INSERT INTO fornecedores (nome_empresa, cnpj, telefone, email, ativo)
SELECT 
    'Fornecedor Tech ' || i || ' LTDA',
    LPAD(((i * 12) % 100)::TEXT, 2, '0') || '.' || 
    LPAD(((i * 345) % 1000)::TEXT, 3, '0') || '.' || 
    LPAD(((i * 678) % 1000)::TEXT, 3, '0') || '/' || 
    LPAD(((i * 9) % 10000)::TEXT, 4, '0') || '-' || 
    LPAD(((i * 3) % 100)::TEXT, 2, '0'),
    '(11) ' || LPAD(((i * 5) % 100000)::TEXT, 5, '0') || '-' || LPAD(((i * 7) % 10000)::TEXT, 4, '0'),
    'contato' || i || '@fornecedor.com.br',
    (i % 10) != 0
FROM generate_series(1, 50) AS i;

-- ============================================
-- 6. INSERIR PRODUTOS (1000 registros)
-- ============================================
INSERT INTO produtos (id_categoria, id_fornecedor, nome_produto, descricao, preco, quantidade_estoque, ativo)
SELECT 
    ((i - 1) % 20) + 1,
    ((i - 1) % 50) + 1,
    CASE ((i - 1) % 20) + 1
        WHEN 1 THEN 'Smartphone Model ' || i
        WHEN 2 THEN 'Notebook Pro ' || i
        WHEN 3 THEN 'Tablet Air ' || i
        WHEN 4 THEN 'Monitor LED ' || i || '" Full HD'
        WHEN 5 THEN 'Teclado Mecânico RGB ' || i
        WHEN 6 THEN 'Mouse Gamer ' || i || ' DPI'
        WHEN 7 THEN 'Fone Bluetooth ' || i
        WHEN 8 THEN 'Webcam HD ' || i
        WHEN 9 THEN 'Impressora Laser ' || i
        WHEN 10 THEN 'Scanner Portátil ' || i
        WHEN 11 THEN 'Roteador WiFi ' || i || ' Dual Band'
        WHEN 12 THEN 'Pen Drive ' || (i % 256) || 'GB USB 3.0'
        WHEN 13 THEN 'HD Externo ' || (i % 4) || 'TB'
        WHEN 14 THEN 'Cabo HDMI ' || i || 'm 4K'
        WHEN 15 THEN 'Carregador Turbo ' || i || 'W'
        WHEN 16 THEN 'Case Premium ' || i
        WHEN 17 THEN 'Suporte Ergonômico ' || i
        WHEN 18 THEN 'Mousepad XL ' || i
        WHEN 19 THEN 'Webcam 4K Pro ' || i
        ELSE 'Kit Gamer RGB ' || i
    END,
    'Produto de alta qualidade para tecnologia e informática. Garantia do fabricante.',
    ROUND((50 + (i * 17) % 5000)::NUMERIC, 2),
    (i * 13) % 500,
    (i % 15) != 0
FROM generate_series(1, 1000) AS i;

-- ============================================
-- 7. INSERIR PEDIDOS (800 registros)
-- ============================================
INSERT INTO pedidos (id_cliente, id_endereco_entrega, data_pedido, status, forma_pagamento, observacoes)
SELECT 
    ((i - 1) % 500) + 1,
    ((i - 1) % 750) + 1,
    CURRENT_TIMESTAMP - ((i * 3) % 365) * INTERVAL '1 day' - ((i * 7) % 24) * INTERVAL '1 hour',
    CASE 
        WHEN (i % 10) = 0 THEN 'PENDENTE'
        WHEN (i % 10) = 1 THEN 'PROCESSANDO'
        WHEN (i % 10) = 2 THEN 'ENVIADO'
        WHEN (i % 10) = 3 THEN 'ENVIADO'
        WHEN (i % 10) = 4 THEN 'ENTREGUE'
        WHEN (i % 10) = 5 THEN 'ENTREGUE'
        WHEN (i % 10) = 6 THEN 'ENTREGUE'
        WHEN (i % 10) = 7 THEN 'ENTREGUE'
        ELSE 'CANCELADO'
    END,
    CASE (i % 4)
        WHEN 0 THEN 'CARTAO_CREDITO'
        WHEN 1 THEN 'PIX'
        WHEN 2 THEN 'CARTAO_DEBITO'
        ELSE 'BOLETO'
    END,
    CASE WHEN i % 5 = 0 THEN 'Entrega no período da manhã' ELSE NULL END
FROM generate_series(1, 800) AS i;

-- ============================================
-- 8. INSERIR ITENS_PEDIDO (2500 registros)
-- ============================================
INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario)
SELECT 
    ((i - 1) % 800) + 1,
    ((i * 17) % 1000) + 1,
    ((i % 5) + 1),
    ROUND((100 + (i * 23) % 3000)::NUMERIC, 2)
FROM generate_series(1, 2500) AS i;

-- ============================================
-- 9. INSERIR AVALIACOES (1500 registros)
-- ============================================
INSERT INTO avaliacoes (id_produto, id_cliente, nota, comentario, data_avaliacao)
SELECT DISTINCT ON (prod_id, cli_id)
    prod_id,
    cli_id,
    nota,
    comentario,
    data_aval
FROM (
    SELECT 
        ((i * 7) % 1000) + 1 AS prod_id,
        ((i * 13) % 500) + 1 AS cli_id,
        ((i % 5) + 1) AS nota,
        CASE (i % 8)
            WHEN 0 THEN 'Produto excelente, recomendo!'
            WHEN 1 THEN 'Muito bom, atendeu minhas expectativas.'
            WHEN 2 THEN 'Ótima qualidade, entrega rápida.'
            WHEN 3 THEN 'Produto bom, mas o preço poderia ser melhor.'
            WHEN 4 THEN 'Atendeu parcialmente, esperava mais.'
            WHEN 5 THEN 'Produto razoável pelo preço.'
            WHEN 6 THEN 'Muito satisfeito com a compra!'
            ELSE 'Produto conforme descrito.'
        END AS comentario,
        CURRENT_TIMESTAMP - ((i * 5) % 180) * INTERVAL '1 day' AS data_aval
    FROM generate_series(1, 2000) AS i
) AS avaliacoes_temp
LIMIT 1500;

COMMIT;

-- ============================================
-- VERIFICAR QUANTIDADE DE REGISTROS
-- ============================================
SELECT 'clientes' AS tabela, COUNT(*) AS total FROM clientes
UNION ALL
SELECT 'emails_clientes', COUNT(*) FROM emails_clientes
UNION ALL
SELECT 'enderecos', COUNT(*) FROM enderecos
UNION ALL
SELECT 'categorias', COUNT(*) FROM categorias
UNION ALL
SELECT 'fornecedores', COUNT(*) FROM fornecedores
UNION ALL
SELECT 'produtos', COUNT(*) FROM produtos
UNION ALL
SELECT 'pedidos', COUNT(*) FROM pedidos
UNION ALL
SELECT 'itens_pedido', COUNT(*) FROM itens_pedido
UNION ALL
SELECT 'avaliacoes', COUNT(*) FROM avaliacoes
ORDER BY tabela;

SELECT 'Dados inseridos com sucesso!' AS mensagem;