
-- Parte 2: Consultas SQL
-- Nome: RENISON

-- Consulta 1: Total vendido por produto em fevereiro de 2025
-- Mostra a quantidade vendida e o valor total em reais.

SELECT
    produto_id,
    SUM(COALESCE(qtde_vendida, 0)) AS quantidade_vendida,
    ROUND(
        SUM(COALESCE(qtde_vendida, 0) * valor_unitario)::numeric, 2
    ) AS total_vendido_reais
FROM public.venda
WHERE data_emissao >= '2025-02-01'
  AND data_emissao < '2025-03-01'
GROUP BY produto_id
ORDER BY total_vendido_reais DESC;


-- Consulta 2: Produtos pedidos e ainda não recebidos completamente.
-- Compara a quantidade solicitada com as entradas de mercadoria.

WITH recebimentos AS (
    SELECT
        ordem_compra,
        produto_id,
        SUM(COALESCE(qtde_recebida, 0)) AS total_recebido
    FROM entradas_mercadoria
    GROUP BY ordem_compra, produto_id
)
SELECT
    p.pedido_id,
    p.ordem_compra,
    p.produto_id,
    p.qtde_pedida,
    p.qtde_entregue AS entregue_no_pedido,
    COALESCE(r.total_recebido, 0) AS recebido_nas_entradas,
    p.qtde_pedida - COALESCE(r.total_recebido, 0) AS quantidade_pendente,
    CASE
        WHEN COALESCE(r.total_recebido, 0) = 0
            THEN 'Nao recebido'
        ELSE 'Recebimento parcial'
    END AS situacao
FROM pedido_compra p
LEFT JOIN recebimentos r
    ON p.ordem_compra = r.ordem_compra
   AND p.produto_id = r.produto_id
WHERE p.qtde_pedida > COALESCE(r.total_recebido, 0)
ORDER BY quantidade_pendente DESC, p.pedido_id;

