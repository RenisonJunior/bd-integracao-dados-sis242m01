
-- Parte 3: Transformacoes SQL
-- Nome: RENISON

-- Transformacao 1: Produtos requisitados mais de 10 vezes.
-- "mais de 10 vezes" significa que o produto
-- apareceu em mais de 10 registros de pedidos no periodo.
-- Nos dados de fevereiro de 2025, nenhum produto atende
-- a esse criterio, pois cada produto aparece no maximo 2 vezes.

SELECT
    CONCAT(produto_id, ' - ', descricao_produto) AS produto,
    SUM(qtde_pedida) AS qtde_requisitada,
    TO_CHAR(MIN(data_pedido), 'DD/MM/YYYY') AS data_solicitacao
FROM pedido_compra
WHERE data_pedido >= '2025-02-01'
  AND data_pedido < '2025-03-01'
GROUP BY produto_id, descricao_produto
HAVING COUNT(*) > 10
ORDER BY qtde_requisitada DESC;


-- Transformacao 2: Consulta complementar por quantidade.
-- Nessa alternativa, consideramos os produtos com mais
-- de 10 unidades requisitadas no periodo.
-- Essa interpretacao e diferente de "mais de 10 vezes".

SELECT
    CONCAT(produto_id, ' - ', descricao_produto) AS produto,
    SUM(qtde_pedida) AS qtde_requisitada,
    TO_CHAR(MIN(data_pedido), 'DD/MM/YYYY') AS data_solicitacao
FROM pedido_compra
WHERE data_pedido >= '2025-02-01'
  AND data_pedido < '2025-03-01'
GROUP BY produto_id, descricao_produto
HAVING SUM(qtde_pedida) > 10
ORDER BY qtde_requisitada DESC;


-- Transformacao 3: Trigger para gerar um novo idfornecedor.
-- Quando um produto for cadastrado sem idfornecedor, a trigger
-- gera um codigo F seguido de numero, cadastra o fornecedor
-- e relaciona esse codigo ao produto.
-- O nome do novo fornecedor deve ser informado previamente.
-- Se um codigo existente for informado, verifica se ele e valido.

CREATE OR REPLACE FUNCTION public.fn_idfornecedor_produto()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_nome TEXT;
    v_numero BIGINT;
BEGIN
    IF NULLIF(BTRIM(NEW.idfornecedor), '') IS NULL THEN

        v_nome := NULLIF(
            BTRIM(current_setting('app.nome_fornecedor', true)),
            ''
        );

        IF v_nome IS NULL THEN
            RAISE EXCEPTION
                'Informe o nome do novo fornecedor antes do cadastro';
        END IF;

        -- Evita que duas execucoes desta trigger gerem o mesmo ID.
        PERFORM pg_advisory_xact_lock(35791);

        -- Procura o maior codigo no formato F1, F2, F3...
        SELECT COALESCE(
            MAX(SUBSTRING(idfornecedor FROM 2)::BIGINT), 0
        ) + 1
        INTO v_numero
        FROM public.fornecedor
        WHERE idfornecedor ~ '^F[0-9]+$';

        NEW.idfornecedor := 'F' || v_numero;

        INSERT INTO public.fornecedor (idfornecedor, razao_social)
        VALUES (NEW.idfornecedor, v_nome);

    ELSIF NOT EXISTS (
        SELECT 1
        FROM public.fornecedor
        WHERE idfornecedor = NEW.idfornecedor
    ) THEN
        RAISE EXCEPTION
            'Fornecedor % nao encontrado', NEW.idfornecedor;
    END IF;

    RETURN NEW;
END;
$$;

-- Permite executar este arquivo novamente sem duplicar a trigger.
DROP TRIGGER IF EXISTS trg_idfornecedor_produto
ON public.produtos_filial;

CREATE TRIGGER trg_idfornecedor_produto
BEFORE INSERT OR UPDATE OF idfornecedor
ON public.produtos_filial
FOR EACH ROW
EXECUTE FUNCTION public.fn_idfornecedor_produto();
