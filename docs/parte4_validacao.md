
# Parte 4: Roteiro de validação com o cliente (fevereiro/2025)

## 1. Pontos a validar

A reunião tem como objetivo apresentar os resultados da integração dos dados e confirmar sua confiabilidade antes do uso em relatórios gerenciais.

As consultas de validação analisaram toda a base importada, incluindo registros de janeiro, fevereiro e março de 2025. Fevereiro de 2025 é o período de referência da reunião.

Os principais pontos que precisam ser confirmados com o cliente são:

1. **Recebimentos superiores aos pedidos:** identificar por que existem entradas de mercadorias em quantidades maiores que as solicitadas.

2. **Divergências nos recebimentos:** conferir as diferenças entre `qtde_entregue`, na tabela `pedido_compra`, e `qtde_recebida`, na tabela `entradas_mercadoria`.

3. **Ordens de compra zeradas:** verificar se o valor `0` representa ausência de ordem, erro de preenchimento ou problema na importação.

4. **Datas inconsistentes:** confirmar o significado de `data_entrega` e investigar registros em que ela é anterior à data do pedido.

5. **Produtos sem cadastro correspondente:** conferir vendas associadas a produtos que não aparecem cadastrados na mesma filial.

6. **Entradas sem pedidos correspondentes:** identificar documentos de entrada que não possuem uma ordem de compra correspondente na base importada.

7. **Colunas adicionais no Excel:** esclarecer a presença de 11 colunas adicionais na aba `pedido_compra`, com informações preenchidas em nove linhas.

Um exemplo importante é o produto P2: o pedido apresenta 14 unidades solicitadas e 7 entregues, enquanto a tabela de entradas registra 64 unidades recebidas. A diferença entre o total recebido e o solicitado é de 50 unidades.

Essa divergência deve ser esclarecida com o cliente antes de qualquer correção.

## 2. Técnicas para garantir exatidão e precisão

Foram utilizadas consultas SQL para identificar possíveis inconsistências entre os registros das tabelas.

As técnicas de validação incluem:

- **Conferência de quantidades:** comparar os valores solicitados, informados como entregues e efetivamente registrados nas entradas.
- **Conciliação entre tabelas:** relacionar pedidos e entradas pelo número da ordem de compra e pelo identificador do produto.
- **Validação temporal:** procurar datas de entrega anteriores às respectivas datas dos pedidos.
- **Verificação de referências:** identificar produtos e ordens de compra sem correspondência nas tabelas relacionadas.
- **Comparação com a fonte original:** verificar divergências entre o PostgreSQL e o arquivo `base_teste.xlsx`.
- **Validação com o cliente:** confirmar o significado dos campos e quais registros representam corretamente as operações realizadas.
- **Registro das evidências:** documentar as consultas, os resultados e as decisões tomadas durante a reunião.

As informações devem ser comparadas, quando disponíveis, com notas fiscais, pedidos originais e registros administrativos.

As inconsistências não devem ser corrigidas automaticamente sem confirmação da origem correta dos dados.

## 3. Consultas preparadas para a reunião

As consultas estão armazenadas no arquivo `sql/04_validacao.sql`.

### Consulta 1 — Recebimentos superiores aos pedidos

Compara a quantidade pedida com o total recebido por ordem de compra e produto.

**Resultado:** 7 registros com recebimentos superiores às quantidades solicitadas.

Exemplo: P2, com 14 unidades pedidas e 64 recebidas.

### Consulta 2 — Divergências entre quantidades entregues e recebidas

Compara `qtde_entregue` com os recebimentos registrados em `entradas_mercadoria`.

**Resultado:** 18 registros com valores diferentes.

Essas diferenças precisam ser esclarecidas, inclusive quanto ao significado operacional de cada campo.

### Consulta 3 — Ordens de compra zeradas

Localiza pedidos em que `ordem_compra = 0`.

**Resultado:** 11 pedidos, de ID 19 a 29.

É necessário confirmar se esses valores indicam pedidos sem ordem cadastrada ou problemas na estrutura da planilha.

### Consulta 4 — Datas anteriores aos pedidos

Identifica registros cuja `data_entrega` é anterior à `data_pedido`.

**Resultado:** 20 registros.

O cliente deverá confirmar se `data_entrega` representa uma entrega efetiva, uma previsão ou outro evento administrativo.

### Consulta 5 — Produtos sem cadastro correspondente

Verifica pedidos e vendas que referenciam produtos não encontrados em `produtos_filial` para a mesma filial.

**Resultado:** 13 registros, todos originados da tabela `venda`.

Os registros devem ser comparados com o cadastro de produtos utilizado na operação.

### Consulta 6 — Entradas sem pedido correspondente

Localiza entradas de mercadorias sem correspondência com `pedido_compra`, utilizando a ordem de compra e o produto.

**Resultado:** 2 registros:

- Ordem 19, produto P19, nota fiscal NFE19.
- Ordem 20, produto P20, nota fiscal NFE20.

Esses registros precisam ser investigados junto aos pedidos com número de ordem zerado.

## Erros encontrados nos dados

A tabela apresenta inconsistências e situações suspeitas encontradas durante a validação.

| Tabela | Problema | Quantidade | Consulta que mostra |
| --- | --- | ---: | --- |
| pedido_compra / entradas_mercadoria | Recebimentos superiores às quantidades solicitadas | 7 | Consulta 1 |
| pedido_compra / entradas_mercadoria | Divergências entre quantidade entregue e quantidade recebida | 18 | Consulta 2 |
| pedido_compra | Ordens de compra com valor zero | 11 | Consulta 3 |
| pedido_compra | Data de entrega anterior à data do pedido | 20 | Consulta 4 |
| venda / produtos_filial | Vendas sem produto correspondente na mesma filial | 13 | Consulta 5 |
| entradas_mercadoria / pedido_compra | Entradas sem pedido correspondente | 2 | Consulta 6 |
| Planilha Excel — pedido_compra | Onze colunas adicionais com informações em nove linhas | 9 linhas | Inspeção da planilha com Python, documentada na Parte 1 |

**Observação:** as quantidades podem se sobrepor, pois um mesmo registro pode apresentar mais de uma inconsistência.

As seis consultas SQL verificam os dados importados. O problema das colunas adicionais foi identificado diretamente na planilha Excel, pois essas colunas não foram incorporadas ao banco.

## Encaminhamentos da reunião

Durante a reunião, serão apresentados os resultados das consultas e exemplos dos registros identificados.

O cliente deverá confirmar os valores corretos e esclarecer as regras utilizadas para registrar pedidos, entregas e entradas de mercadorias.

Após essa confirmação, as correções necessárias poderão ser planejadas, preservando o histórico das alterações e evitando modificações sem justificativa.

A validação permitirá melhorar a confiabilidade dos dados utilizados nos relatórios e nas decisões da organização.
