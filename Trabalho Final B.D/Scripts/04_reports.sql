-- ============================================
-- SISTEMA E-COMMERCE - TECHSTORE BRASIL
-- Relatórios e Consultas Avançadas
-- ============================================

-- ============================================
-- RELATÓRIO 1: Top 10 Clientes que Mais Compraram (por valor)
-- ============================================
-- Objetivo: Identificar os melhores clientes da loja
SELECT 
    c.id_cliente,
    c.nome_completo,
    c.cpf,
    COUNT(DISTINCT p.id_pedido) AS total_pedidos,
    SUM(ip.quantidade * ip.preco_unitario) AS valor_total_gasto,
    ROUND(AVG(ip.quantidade * ip.preco_unitario), 2) AS ticket_medio
FROM clientes c
INNER JOIN pedidos p ON c.id_cliente = p.id_cliente
INNER JOIN itens_pedido ip ON p.id_pedido = ip.id_pedido
WHERE p.status != 'CANCELADO'
GROUP BY c.id_cliente, c.nome_completo, c.cpf
ORDER BY valor_total_gasto DESC
LIMIT 10;

-- ============================================
-- RELATÓRIO 2: Produtos Mais Vendidos
-- ============================================
-- Objetivo: Identificar os produtos campeões de venda
SELECT 
    pr.id_produto,
    pr.nome_produto,
    cat.nome_categoria,
    COUNT(ip.id_item) AS vezes_vendido,
    SUM(ip.quantidade) AS quantidade_total_vendida,
    SUM(ip.quantidade * ip.preco_unitario) AS receita_total,
    ROUND(AVG(COALESCE(a.nota, 0)), 2) AS media_avaliacoes
FROM produtos pr
INNER JOIN itens_pedido ip ON pr.id_produto = ip.id_produto
INNER JOIN pedidos p ON ip.id_pedido = p.id_pedido
INNER JOIN categorias cat ON pr.id_categoria = cat.id_categoria
LEFT JOIN avaliacoes a ON pr.id_produto = a.id_produto
WHERE p.status != 'CANCELADO'
GROUP BY pr.id_produto, pr.nome_produto, cat.nome_categoria
ORDER BY quantidade_total_vendida DESC
LIMIT 15;

-- ============================================
-- RELATÓRIO 3: Vendas por Categoria
-- ============================================
-- Objetivo: Analisar performance das categorias de produtos
SELECT 
    cat.nome_categoria,
    COUNT(DISTINCT pr.id_produto) AS total_produtos,
    COUNT(DISTINCT ip.id_pedido) AS total_pedidos,
    SUM(ip.quantidade) AS quantidade_vendida,
    SUM(ip.quantidade * ip.preco_unitario) AS receita_total,
    ROUND(AVG(ip.preco_unitario), 2) AS preco_medio
FROM categorias cat
INNER JOIN produtos pr ON cat.id_categoria = pr.id_categoria
INNER JOIN itens_pedido ip ON pr.id_produto = ip.id_produto
INNER JOIN pedidos p ON ip.id_pedido = p.id_pedido
WHERE p.status != 'CANCELADO'
GROUP BY cat.id_categoria, cat.nome_categoria
ORDER BY receita_total DESC;

-- ============================================
-- RELATÓRIO 4: Análise de Pedidos por Status
-- ============================================
-- Objetivo: Acompanhar o status dos pedidos
SELECT 
    status,
    COUNT(*) AS quantidade_pedidos,
    SUM(valor_total) AS receita_total,
    ROUND(AVG(valor_total), 2) AS valor_medio,
    MIN(valor_total) AS menor_pedido,
    MAX(valor_total) AS maior_pedido
FROM (
    SELECT 
        p.id_pedido,
        p.status,
        SUM(ip.quantidade * ip.preco_unitario) AS valor_total
    FROM pedidos p
    INNER JOIN itens_pedido ip ON p.id_pedido = ip.id_pedido
    GROUP BY p.id_pedido, p.status
) AS pedidos_com_valor
GROUP BY status
ORDER BY 
    CASE status
        WHEN 'PENDENTE' THEN 1
        WHEN 'PROCESSANDO' THEN 2
        WHEN 'ENVIADO' THEN 3
        WHEN 'ENTREGUE' THEN 4
        WHEN 'CANCELADO' THEN 5
    END;

-- ============================================
-- RELATÓRIO 5: Produtos com Baixo Estoque
-- ============================================
-- Objetivo: Identificar produtos que precisam de reposição
SELECT 
    pr.id_produto,
    pr.nome_produto,
    cat.nome_categoria,
    f.nome_empresa AS fornecedor,
    pr.quantidade_estoque,
    pr.preco,
    COUNT(ip.id_item) AS vezes_vendido_ultimos_30_dias
FROM produtos pr
INNER JOIN categorias cat ON pr.id_categoria = cat.id_categoria
INNER JOIN fornecedores f ON pr.id_fornecedor = f.id_fornecedor
LEFT JOIN itens_pedido ip ON pr.id_produto = ip.id_produto
LEFT JOIN pedidos p ON ip.id_pedido = p.id_pedido 
    AND p.data_pedido >= CURRENT_TIMESTAMP - INTERVAL '30 days'
    AND p.status != 'CANCELADO'
WHERE pr.quantidade_estoque < 50 AND pr.ativo = TRUE
GROUP BY pr.id_produto, pr.nome_produto, cat.nome_categoria, f.nome_empresa, pr.quantidade_estoque, pr.preco
ORDER BY pr.quantidade_estoque ASC, vezes_vendido_ultimos_30_dias DESC
LIMIT 20;

-- ============================================
-- RELATÓRIO 6: Faturamento por Período (Últimos 12 Meses)
-- ============================================
-- Objetivo: Analisar evolução das vendas mensalmente
SELECT 
    TO_CHAR(p.data_pedido, 'YYYY-MM') AS mes_ano,
    COUNT(DISTINCT p.id_pedido) AS total_pedidos,
    COUNT(DISTINCT p.id_cliente) AS clientes_unicos,
    SUM(ip.quantidade) AS produtos_vendidos,
    SUM(ip.quantidade * ip.preco_unitario) AS receita_total,
    ROUND(AVG(ip.quantidade * ip.preco_unitario), 2) AS ticket_medio
FROM pedidos p
INNER JOIN itens_pedido ip ON p.id_pedido = ip.id_pedido
WHERE p.status != 'CANCELADO'
    AND p.data_pedido >= CURRENT_TIMESTAMP - INTERVAL '12 months'
GROUP BY TO_CHAR(p.data_pedido, 'YYYY-MM')
ORDER BY mes_ano DESC;

-- ============================================
-- RELATÓRIO 7: Avaliações de Produtos (Melhor e Pior Avaliados)
-- ============================================
-- Objetivo: Identificar satisfação dos clientes com os produtos
SELECT 
    pr.id_produto,
    pr.nome_produto,
    cat.nome_categoria,
    COUNT(a.id_avaliacao) AS total_avaliacoes,
    ROUND(AVG(a.nota), 2) AS media_nota,
    SUM(CASE WHEN a.nota = 5 THEN 1 ELSE 0 END) AS avaliacoes_5_estrelas,
    SUM(CASE WHEN a.nota = 1 THEN 1 ELSE 0 END) AS avaliacoes_1_estrela
FROM produtos pr
INNER JOIN categorias cat ON pr.id_categoria = cat.id_categoria
INNER JOIN avaliacoes a ON pr.id_produto = a.id_produto
GROUP BY pr.id_produto, pr.nome_produto, cat.nome_categoria
HAVING COUNT(a.id_avaliacao) >= 3
ORDER BY media_nota DESC, total_avaliacoes DESC
LIMIT 20;

-- ============================================
-- RELATÓRIO 8: Performance dos Fornecedores
-- ============================================
-- Objetivo: Avaliar fornecedores por vendas e avaliações
SELECT 
    f.id_fornecedor,
    f.nome_empresa,
    f.cnpj,
    COUNT(DISTINCT pr.id_produto) AS total_produtos,
    COUNT(DISTINCT ip.id_pedido) AS produtos_vendidos,
    SUM(ip.quantidade * ip.preco_unitario) AS receita_gerada,
    ROUND(AVG(a.nota), 2) AS media_avaliacoes,
    COUNT(a.id_avaliacao) AS total_avaliacoes
FROM fornecedores f
INNER JOIN produtos pr ON f.id_fornecedor = pr.id_fornecedor
LEFT JOIN itens_pedido ip ON pr.id_produto = ip.id_produto
LEFT JOIN pedidos p ON ip.id_pedido = p.id_pedido AND p.status != 'CANCELADO'
LEFT JOIN avaliacoes a ON pr.id_produto = a.id_produto
WHERE f.ativo = TRUE
GROUP BY f.id_fornecedor, f.nome_empresa, f.cnpj
ORDER BY receita_gerada DESC
LIMIT 15;

-- ============================================
-- RELATÓRIO 9: Análise de Formas de Pagamento
-- ============================================
-- Objetivo: Entender preferências de pagamento dos clientes
SELECT 
    p.forma_pagamento,
    COUNT(*) AS total_pedidos,
    SUM(ip.quantidade * ip.preco_unitario) AS receita_total,
    ROUND(AVG(ip.quantidade * ip.preco_unitario), 2) AS ticket_medio,
    ROUND(COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER () * 100, 2) AS percentual_uso,
    COUNT(DISTINCT p.id_cliente) AS clientes_unicos
FROM pedidos p
INNER JOIN itens_pedido ip ON p.id_pedido = ip.id_pedido
WHERE p.status != 'CANCELADO'
GROUP BY p.forma_pagamento
ORDER BY total_pedidos DESC;

-- ============================================
-- RELATÓRIO 10: Clientes por Localização (Cidade/Estado)
-- ============================================
-- Objetivo: Identificar distribuição geográfica dos clientes
SELECT 
    e.cidade,
    e.estado,
    COUNT(DISTINCT c.id_cliente) AS total_clientes,
    COUNT(DISTINCT p.id_pedido) AS total_pedidos,
    SUM(ip.quantidade * ip.preco_unitario) AS receita_total,
    ROUND(AVG(ip.quantidade * ip.preco_unitario), 2) AS ticket_medio,
    ROUND(COUNT(DISTINCT c.id_cliente)::NUMERIC / SUM(COUNT(DISTINCT c.id_cliente)) OVER () * 100, 2) AS percentual_clientes
FROM enderecos e
INNER JOIN clientes c ON e.id_cliente = c.id_cliente
LEFT JOIN pedidos p ON c.id_cliente = p.id_cliente AND p.status != 'CANCELADO'
LEFT JOIN itens_pedido ip ON p.id_pedido = ip.id_pedido
GROUP BY e.cidade, e.estado
ORDER BY total_clientes DESC, receita_total DESC
LIMIT 15;

SELECT 'Relatórios gerados com sucesso!' AS mensagem;