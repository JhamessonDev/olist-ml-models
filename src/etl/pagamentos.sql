WITH tb_pedidos AS (

    SELECT DISTINCT
        t1.order_id,
        t2.seller_id

    FROM tb_orders AS t1

    LEFT JOIN tb_order_items AS t2
    ON t1.order_id = t2.order_id

    WHERE t1.order_purchase_timestamp < '2018-01-01'
    AND t1.order_purchase_timestamp >= DATE('2018-01-01', '-6 months')
    AND t2.seller_id IS NOT NULL
),

tb_join AS (

    SELECT
        t1.seller_id,
        t2.*

    FROM tb_pedidos AS t1

    LEFT JOIN tb_order_payments AS t2
    ON t1.order_id = t2.order_id
),

tb_group AS (

    SELECT 
        seller_id,
        payment_type,
        count(DISTINCT t2.order_id) as qtdePedidoMeioPagamento,
        sum(t2.payment_value) as vlPedidoMeioPagamento

    FROM tb_join t2

    GROUP BY seller_id, payment_type

    ORDER BY seller_id, payment_type
),

tb_summary AS (

    SELECT 

        seller_id,
        sum(case when payment_type='boleto' then qtdePedidoMeioPagamento else 0 end) as qtde_boleto_pedido,
        sum(case when payment_type='credit_card' then qtdePedidoMeioPagamento else 0 end) as qtde_credit_card_pedido,
        sum(case when payment_type='voucher' then qtdePedidoMeioPagamento else 0 end) as qtde_voucher_pedido,
        sum(case when payment_type='debit_card' then qtdePedidoMeioPagamento else 0 end) as qtde_debit_card_pedido,

        sum(case when payment_type='boleto' then vlPedidoMeioPagamento else 0 end) as valor_boleto_pedido,
        sum(case when payment_type='credit_card' then vlPedidoMeioPagamento else 0 end) as valor_credit_card_pedido,
        sum(case when payment_type='voucher' then vlPedidoMeioPagamento else 0 end) as valor_voucher_pedido,
        sum(case when payment_type='debit_card' then vlPedidoMeioPagamento else 0 end) as valor_debit_card_pedido,
        
        sum(case when payment_type='boleto' then qtdePedidoMeioPagamento else 0 end) * 1.0 / sum(qtdePedidoMeioPagamento) as pct_qtd_boleto_pedido,
        sum(case when payment_type='credit_card' then qtdePedidoMeioPagamento else 0 end) * 1.0 / sum(qtdePedidoMeioPagamento) as pct_qtd_credit_card_pedido,
        sum(case when payment_type='voucher' then qtdePedidoMeioPagamento else 0 end) * 1.0 / sum(qtdePedidoMeioPagamento) as pct_qtd_voucher_pedido,
        sum(case when payment_type='debit_card' then qtdePedidoMeioPagamento else 0 end) * 1.0 / sum(qtdePedidoMeioPagamento) as pct_qtd_debit_card_pedido,

        sum(case when payment_type='boleto' then vlPedidoMeioPagamento else 0 end) * 1.0 / sum(vlPedidoMeioPagamento) as pct_valor_boleto_pedido,
        sum(case when payment_type='credit_card' then vlPedidoMeioPagamento else 0 end) * 1.0 / sum(vlPedidoMeioPagamento) as pct_valor_credit_card_pedido,
        sum(case when payment_type='voucher' then vlPedidoMeioPagamento else 0 end) * 1.0 / sum(vlPedidoMeioPagamento) as pct_valor_voucher_pedido,
        sum(case when payment_type='debit_card' then vlPedidoMeioPagamento else 0 end) * 1.0 / sum(vlPedidoMeioPagamento) as pct_valor_debit_card_pedido
    
    FROM tb_group
    
    GROUP BY seller_id
),

tb_cartao AS (

    SELECT 
        seller_id,
        AVG(payment_sequential) AS avgQtdeParcelas,
        -- PERCENTILE(nrParcelas, 0.5) AS medianQtdeParcelas,
        MAX(payment_sequential) AS maxQtdeParcelas,
        MIN(payment_sequential) AS minQtdeParcelas

    FROM tb_join

    WHERE payment_type = 'credit_card'

    GROUP BY seller_id
)

SELECT
    t1.*,
    '2018-01-01' AS dtReference
    t2.avgQtdeParcelas,
    -- t2.medianQtdeParcelas,
    t2.maxQtdeParcelas,
    t2.minQtdeParcelas


FROM tb_summary AS T1

LEFT JOIN tb_cartao AS t2
ON t1.seller_id = t2.seller_id