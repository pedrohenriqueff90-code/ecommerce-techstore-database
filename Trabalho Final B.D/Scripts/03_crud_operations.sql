-- ============================================
-- SISTEMA E-COMMERCE - TECHSTORE BRASIL
-- Operações CRUD (Create, Read, Update, Delete)
-- ============================================

-- ============================================
-- CREATE (INSERÇÃO DE DADOS)
-- ============================================

-- 1. Inserir novo cliente
INSERT INTO clientes (nome_completo, cpf, data_nascimento)
VALUES ('Roberto Mendes Junior', '123.456.789-00', '1990-05-15')
RETURNING *;

-- 2. Inserir email para o cliente
INSERT INTO emails_clientes (id_cliente, email, principal)
VALUES (501, 'roberto.mendes@email.com', TRUE)
RETURNING *;

-- 3. Inserir endereço para o cliente
INSERT INTO enderecos (id_cliente, rua, numero, complemento, bairro, cidade, estado, cep, tipo_endereco)
VALUES (501, 'Rua dos Desenvolvedores', '1000', 'Sala 10', 'Tech Park', 'São Paulo', 'SP', '01234-567', 'COMERCIAL')
RETURNING *;

-- 4. Inserir nova categoria
INSERT INTO categorias (nome_categoria, descricao, ativa)
VALUES ('Smartwatches', 'Relógios inteligentes e wearables', TRUE)
RETURNING *;

-- 5. Inserir novo fornecedor
INSERT INTO fornecedores (nome_empresa, cnpj, telefone, email)
VALUES ('TechSupply Distribuição LTDA', '12.345.678/0001-90', '(11) 98765-4321', 'contato@techsupply.com.br')
RETURNING *;

-- 6. Inserir novo produto
INSERT INTO produtos (id_categoria, id_fornecedor, nome_produto, descricao, preco, quantidade_estoque)
VALUES (21, 51, 'Smartwatch Ultra Pro', 'Smartwatch com GPS, monitor cardíaco e resistência à água', 1299.90, 50)
RETURNING *;

-- 7. Inserir novo pedido
INSERT INTO pedidos (id_cliente, id_endereco_entrega, status, forma_pagamento, observacoes)
VALUES (501, 751, 'PENDENTE', 'PIX', 'Entregar após às 14h')
RETURNING *;

-- 8. Inserir itens no pedido
INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario)
VALUES 
    (801, 1001, 1, 1299.90),
    (801, 5, 1, 899.90)
RETURNING *;

-- 9. Inserir avaliação de produto
INSERT INTO avaliacoes (id_produto, id_cliente, nota, comentario)
VALUES (1, 1, 5, 'Produto excelente! Superou minhas expectativas. Entrega rápida e bem embalado.')
RETURNING *;

-- ============================================
-- READ (CONSULTA DE DADOS)
-- ============================================

-- 1. Buscar todos os clientes ativos
SELECT * FROM clientes WHERE ativo = TRUE ORDER BY nome_completo LIMIT 10;

-- 2. Buscar cliente específico por CPF
SELECT * FROM clientes WHERE cpf = '123.456.789-00';

-- 3. Buscar cliente com seus emails
SELECT 
    c.id_cliente,
    c.nome_completo,
    c.cpf,
    e.email,
    e.principal
FROM clientes c
INNER JOIN emails_clientes e ON c.id_cliente = e.id_cliente
WHERE c.id_cliente = 1;

-- 4. Buscar cliente com idade (atributo derivado)
SELECT 
    id_cliente,
    nome_completo,
    data_nascimento,
    DATE_PART('year', AGE(CURRENT_DATE, data_nascimento))::INTEGER AS idade
FROM clientes
WHERE id_cliente = 1;

-- 5. Buscar endereço completo de um cliente (atributo composto)
SELECT 
    id_endereco,
    rua || ', ' || numero || 
    COALESCE(', ' || complemento, '') || ' - ' || 
    bairro || ', ' || cidade || ' - ' || estado || ', CEP: ' || cep AS endereco_completo,
    tipo_endereco
FROM enderecos
WHERE id_cliente = 1;

-- 6. Listar produtos por categoria
SELECT 
    p.id_produto,
    p.nome_produto,
    c.nome_categoria,
    p.preco,
    p.quantidade_estoque
FROM produtos p
INNER JOIN categorias c ON p.id_categoria = c.id_categoria
WHERE c.nome_categoria = 'Smartphones'
ORDER BY p.preco DESC
LIMIT 10;

-- 7. Buscar produtos de um fornecedor
SELECT 
    p.nome_produto,
    f.nome_empresa AS fornecedor,
    p.preco,
    p.quantidade_estoque
FROM produtos p
INNER JOIN fornecedores f ON p.id_fornecedor = f.id_fornecedor
WHERE f.id_fornecedor = 1
ORDER BY p.nome_produto
LIMIT 10;

-- 8. Buscar pedidos de um cliente
SELECT 
    pe.id_pedido,
    pe.data_pedido,
    pe.status,
    pe.forma_pagamento,
    SUM(ip.quantidade * ip.preco_unitario) AS valor_total
FROM pedidos pe
INNER JOIN itens_pedido ip ON pe.id_pedido = ip.id_pedido
WHERE pe.id_cliente = 1
GROUP BY pe.id_pedido
ORDER BY pe.data_pedido DESC;

-- 9. Buscar detalhes completos de um pedido
SELECT 
    pe.id_pedido,
    c.nome_completo AS cliente,
    pe.data_pedido,
    pe.status,
    pr.nome_produto,
    ip.quantidade,
    ip.preco_unitario,
    (ip.quantidade * ip.preco_unitario) AS subtotal
FROM pedidos pe
INNER JOIN clientes c ON pe.id_cliente = c.id_cliente
INNER JOIN itens_pedido ip ON pe.id_pedido = ip.id_pedido
INNER JOIN produtos pr ON ip.id_produto = pr.id_produto
WHERE pe.id_pedido = 1
ORDER BY pr.nome_produto;

-- 10. Buscar avaliações de um produto
SELECT 
    a.nota,
    a.comentario,
    a.data_avaliacao,
    c.nome_completo AS cliente
FROM avaliacoes a
INNER JOIN clientes c ON a.id_cliente = c.id_cliente
WHERE a.id_produto = 1
ORDER BY a.data_avaliacao DESC
LIMIT 10;

-- 11. Buscar produtos com média de avaliações (atributo derivado)
SELECT 
    p.id_produto,
    p.nome_produto,
    p.preco,
    COALESCE(ROUND(AVG(a.nota), 2), 0) AS media_avaliacoes,
    COUNT(a.id_avaliacao) AS total_avaliacoes
FROM produtos p
LEFT JOIN avaliacoes a ON p.id_produto = a.id_produto
WHERE p.id_produto = 1
GROUP BY p.id_produto;

-- ============================================
-- UPDATE (ATUALIZAÇÃO DE DADOS)
-- ============================================

-- 1. Atualizar dados do cliente
UPDATE clientes
SET nome_completo = 'Roberto Mendes Junior Silva',
    ativo = TRUE
WHERE id_cliente = 501
RETURNING *;

-- 2. Atualizar email do cliente
UPDATE emails_clientes
SET email = 'roberto.mendes.novo@email.com'
WHERE id_cliente = 501 AND principal = TRUE
RETURNING *;

-- 3. Atualizar endereço
UPDATE enderecos
SET numero = '1001',
    complemento = 'Sala 11'
WHERE id_endereco = 751
RETURNING *;

-- 4. Atualizar preço de produto
UPDATE produtos
SET preco = 1199.90,
    quantidade_estoque = quantidade_estoque + 20
WHERE id_produto = 1001
RETURNING *;

-- 5. Atualizar status do pedido
UPDATE pedidos
SET status = 'PROCESSANDO'
WHERE id_pedido = 801
RETURNING *;

-- 6. Atualizar quantidade de item no pedido
UPDATE itens_pedido
SET quantidade = 2
WHERE id_item = 1
RETURNING *;

-- 7. Atualizar avaliação
UPDATE avaliacoes
SET nota = 5,
    comentario = 'Excelente produto! Atualizando minha avaliação após uso prolongado.'
WHERE id_avaliacao = 1
RETURNING *;

-- 8. Desativar categoria
UPDATE categorias
SET ativa = FALSE
WHERE id_categoria = 21
RETURNING *;

-- 9. Desativar fornecedor
UPDATE fornecedores
SET ativo = FALSE
WHERE id_fornecedor = 51
RETURNING *;

-- 10. Atualizar estoque após venda (diminuir)
UPDATE produtos
SET quantidade_estoque = quantidade_estoque - 1
WHERE id_produto = 1
RETURNING quantidade_estoque;

-- 11. Atualizar estoque após recebimento (aumentar)
UPDATE produtos
SET quantidade_estoque = quantidade_estoque + 50
WHERE id_produto = 1
RETURNING quantidade_estoque;

-- ============================================
-- DELETE (EXCLUSÃO DE DADOS)
-- ============================================

-- 1. Deletar avaliação específica
DELETE FROM avaliacoes
WHERE id_avaliacao = 1500
RETURNING *;

-- 2. Deletar item de um pedido
DELETE FROM itens_pedido
WHERE id_item = 2500
RETURNING *;

-- 3. Deletar pedido (CASCADE irá deletar itens_pedido relacionados)
DELETE FROM pedidos
WHERE id_pedido = 800
RETURNING *;

-- 4. Deletar email secundário de cliente
DELETE FROM emails_clientes
WHERE id_email = 1000
RETURNING *;

-- 5. Deletar endereço não utilizado
DELETE FROM enderecos
WHERE id_endereco = 750
RETURNING *;

-- 6. Deletar produto (será impedido se houver itens_pedido ou avaliacoes relacionados)
-- Primeiro devemos deletar as dependências ou usar CASCADE
DELETE FROM avaliacoes WHERE id_produto = 1000;
DELETE FROM itens_pedido WHERE id_produto = 1000;
DELETE FROM produtos WHERE id_produto = 1000 RETURNING *;

-- 7. Deletar categoria sem produtos
DELETE FROM categorias
WHERE id_categoria = 21 AND NOT EXISTS (
    SELECT 1 FROM produtos WHERE id_categoria = 21
)
RETURNING *;

-- 8. Deletar fornecedor sem produtos
DELETE FROM fornecedores
WHERE id_fornecedor = 50 AND NOT EXISTS (
    SELECT 1 FROM produtos WHERE id_fornecedor = 50
)
RETURNING *;

-- 9. Deletar cliente (CASCADE irá deletar emails, endereços, pedidos relacionados)
-- CUIDADO: Isso irá deletar muitos dados relacionados!
DELETE FROM clientes
WHERE id_cliente = 500
RETURNING *;

-- 10. Deletar registros antigos (exemplo: pedidos cancelados há mais de 1 ano)
DELETE FROM pedidos
WHERE status = 'CANCELADO' 
AND data_pedido < CURRENT_TIMESTAMP - INTERVAL '1 year'
RETURNING id_pedido, data_pedido, status;

-- ============================================
-- OPERAÇÕES CRUD COMPLEXAS (TRANSAÇÕES)
-- ============================================

-- Exemplo 1: Criar pedido completo (transação)
BEGIN;

-- Inserir pedido
INSERT INTO pedidos (id_cliente, id_endereco_entrega, status, forma_pagamento)
VALUES (1, 1, 'PENDENTE', 'PIX')
RETURNING id_pedido;

-- Inserir itens (supondo id_pedido = 802)
INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario)
VALUES 
    (802, 1, 2, 899.90),
    (802, 5, 1, 599.90);

-- Atualizar estoque
UPDATE produtos SET quantidade_estoque = quantidade_estoque - 2 WHERE id_produto = 1;
UPDATE produtos SET quantidade_estoque = quantidade_estoque - 1 WHERE id_produto = 5;

COMMIT;

-- Exemplo 2: Cancelar pedido (transação)
BEGIN;

-- Buscar itens do pedido para devolver ao estoque
SELECT id_produto, quantidade FROM itens_pedido WHERE id_pedido = 802;

-- Devolver itens ao estoque
UPDATE produtos p
SET quantidade_estoque = quantidade_estoque + ip.quantidade
FROM itens_pedido ip
WHERE p.id_produto = ip.id_produto AND ip.id_pedido = 802;

-- Atualizar status do pedido
UPDATE pedidos SET status = 'CANCELADO' WHERE id_pedido = 802;

COMMIT;

SELECT 'Operações CRUD executadas com sucesso!' AS mensagem;