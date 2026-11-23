
-- Parte 4: Validacao dos dados
-- Nome: RENISON
-- Periodo de referencia: fevereiro de 2025
-- Consultas somente de leitura: nao alteram os dados.

-- Validacao 1: Recebimentos maiores que os pedidos.
-- Exemplo investigado: produto P2.

WITH recebimentos AS (
    SELECT ordem_compra, produto_id,
           SUM(qtde_recebida) AS total_recebido
    FROM entradas_mercadoria
    GROUP BY ordem_compra, produto_id
)
SELECT
    p.pedido_id,
    p.ordem_compra,
    p.produto_id,
    p.qtde_pedida,
    r.total_recebido,
    r.total_recebido - p.qtde_pedida AS quantidade_excedente
FROM pedido_compra p
JOIN recebimentos r
    ON p.ordem_compra = r.ordem_compra
   AND p.produto_id = r.produto_id
WHERE r.total_recebido > p.qtde_pedida
ORDER BY quantidade_excedente DESC;


-- Validacao 2: Divergencia entre a quantidade entregue
-- informada no pedido e o recebimento registrado.

WITH recebimentos AS (
    SELECT ordem_compra, produto_id,
           SUM(qtde_recebida) AS total_recebido
    FROM entradas_mercadoria
    GROUP BY ordem_compra, produto_id
)
SELECT
    p.pedido_id,
    p.produto_id,
    p.ordem_compra,
    p.qtde_entregue AS entregue_no_pedido,
    r.total_recebido AS recebido_na_entrada
FROM pedido_compra p
JOIN recebimentos r
    ON p.ordem_compra = r.ordem_compra
   AND p.produto_id = r.produto_id
WHERE p.qtde_entregue IS DISTINCT FROM r.total_recebido
ORDER BY p.pedido_id;


-- Validacao 3: Pedidos com ordem de compra igual a zero.
-- Precisam ser conferidos com os dados originais.

SELECT
    pedido_id,
    produto_id,
    ordem_compra,
    qtde_pedida,
    qtde_entregue
FROM pedido_compra
WHERE ordem_compra = 0
ORDER BY pedido_id;


-- Validacao 4: Data de entrega anterior a data do pedido.

SELECT
    pedido_id,
    produto_id,
    TO_CHAR(data_pedido, 'DD/MM/YYYY') AS data_pedido,
    TO_CHAR(data_entrega, 'DD/MM/YYYY') AS data_entrega
FROM pedido_compra
WHERE data_entrega < data_pedido
ORDER BY pedido_id;


-- Validacao 5: Produtos referenciados sem cadastro
-- correspondente na mesma filial.

SELECT
    'pedido_compra' AS tabela_origem,
    p.pedido_id::TEXT AS registro_id,
    p.filial_id,
    p.produto_id
FROM pedido_compra p
WHERE NOT EXISTS (
    SELECT 1
    FROM produtos_filial pf
    WHERE pf.filial_id = p.filial_id
      AND pf.produto_id = p.produto_id
)

UNION ALL

SELECT
    'venda' AS tabela_origem,
    v.venda_id::TEXT AS registro_id,
    v.filial_id,
    v.produto_id
FROM venda v
WHERE NOT EXISTS (
    SELECT 1
    FROM produtos_filial pf
    WHERE pf.filial_id = v.filial_id
      AND pf.produto_id = v.produto_id
)
ORDER BY tabela_origem, registro_id;


-- Validacao 6: Entradas sem pedido correspondente.
-- Relacionamento pela ordem de compra e produto.

SELECT
    e.ordem_compra,
    e.produto_id,
    e.qtde_recebida,
    e.nro_nfe
FROM entradas_mercadoria e
WHERE NOT EXISTS (
    SELECT 1
    FROM pedido_compra p
    WHERE p.ordem_compra = e.ordem_compra
      AND p.produto_id = e.produto_id
)
ORDER BY e.ordem_compra, e.produto_id;
