-- DDL corrigido para PostgreSQL

-- DDL corrigido para PostgreSQL
-- Atividade de Integracao de Dados
-- Parte 1: Criacao das tabelas

-- 1. Tabela de vendas
CREATE TABLE public.venda (
    venda_id int8 NOT NULL,
    data_emissao date NOT NULL,
    horariomov varchar(8) DEFAULT '00:00:00' NOT NULL,
    produto_id varchar(25) DEFAULT '' NOT NULL,
    qtde_vendida float8 NULL,
    valor_unitario numeric(12,4) DEFAULT 0 NOT NULL,
    filial_id int8 DEFAULT 1 NOT NULL,
    item int4 DEFAULT 0 NOT NULL,
    unidade_medida varchar(3) NULL,
    CONSTRAINT pk_consumo PRIMARY KEY
        (filial_id, venda_id, data_emissao, produto_id, item, horariomov)
);

-- 2. Tabela de pedidos de compra
CREATE TABLE public.pedido_compra (
    pedido_id float8 DEFAULT 0 NOT NULL,
    data_pedido date NULL,
    item float8 DEFAULT 0 NOT NULL,
    produto_id varchar(25) DEFAULT '0' NOT NULL,
    descricao_produto varchar(255) NULL,
    ordem_compra float8 DEFAULT 0 NOT NULL,
    qtde_pedida float8 NULL,
    filial_id int4 NULL,
    data_entrega date NULL,
    qtde_entregue float8 DEFAULT 0 NOT NULL,
    qtde_pendente float8 DEFAULT 0 NOT NULL,
    preco_compra float8 DEFAULT 0 NULL,
    fornecedor_id int4 DEFAULT 0 NULL,
    CONSTRAINT pedido_compra_pkey PRIMARY KEY
        (pedido_id, produto_id, item)
);

-- 3. Tabela de entradas de mercadoria
-- Correcao: adicionada a coluna ordem_compra
CREATE TABLE public.entradas_mercadoria (
    data_entrada date NULL,
    nro_nfe varchar(255) NOT NULL,
    item float8 DEFAULT 0 NOT NULL,
    produto_id varchar(25) DEFAULT '0' NOT NULL,
    descricao_produto varchar(255) NULL,
    ordem_compra float8 DEFAULT 0 NOT NULL,
    qtde_recebida float8 NULL,
    filial_id int4 NULL,
    custo_unitario numeric(12,4) DEFAULT 0 NOT NULL,
    CONSTRAINT entradas_mercadoria_pkey PRIMARY KEY
        (ordem_compra, item, produto_id, nro_nfe)
);

-- 4. Tabela de produtos por filial
-- Correcao: nomes das colunas, tipos e chave primaria
CREATE TABLE public.produtos_filial (
    filial_id int4 NOT NULL,
    produto_id varchar(255) NOT NULL,
    descricao varchar(255) NOT NULL,
    estoque float8 DEFAULT 0 NOT NULL,
    preco_unitario float8 DEFAULT 0 NOT NULL,
    preco_compra float8 DEFAULT 0 NOT NULL,
    preco_venda float8 DEFAULT 0 NOT NULL,
    idfornecedor varchar(25) NULL,
    CONSTRAINT produtos_filial_pkey PRIMARY KEY
        (filial_id, produto_id)
);

-- 5. Tabela de fornecedores
-- Correcao: nome do identificador e chave primaria
CREATE TABLE public.fornecedor (
    idfornecedor varchar(25) NOT NULL,
    razao_social varchar(255) NOT NULL,
    CONSTRAINT fornecedor_pkey PRIMARY KEY (idfornecedor)
);
