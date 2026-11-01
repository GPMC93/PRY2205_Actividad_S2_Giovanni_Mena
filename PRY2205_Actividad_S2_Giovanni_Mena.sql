/* =====================================================
   CASO 1 - ANÁLISIS DE FACTURAS
   ===================================================== */
   
SELECT numfactura AS "N° Factura",
       TO_CHAR(fecha, 'DD "de" Month YYYY') AS "Fecha Emisión",
       LPAD(rutcliente, 10, '0') AS "RUT Cliente",
       TO_CHAR(neto, 'FM$999G999G999') AS "Monto Neto",
       TO_CHAR(iva, 'FM$999G999G999') AS "Monto IVA",
       TO_CHAR(total, 'FM$999G999G999') AS "Total Factura",
       CASE
         WHEN total BETWEEN 0 AND 50000 THEN 'Bajo'
         WHEN total BETWEEN 50001 AND 100000 THEN 'Medio'
         ELSE 'Alto'
         END AS "Categoría Monto",
       CASE
         WHEN codpago = 1 THEN 'EFECTIVO'
         WHEN codpago = 2 THEN 'TARJETA DEBITO'
         WHEN codpago = 3 THEN 'TARJETA CREDITO'
         ELSE 'CHEQUE'
         END AS "Forma de Pago"
FROM factura
WHERE EXTRACT(YEAR FROM fecha) = EXTRACT(YEAR FROM SYSDATE) - 1
ORDER BY fecha DESC, neto DESC;

/* =====================================================
   CASO 2 - CLASIFICACIÓN DE CLIENTES
   ===================================================== */
   
SELECT LPAD(rutcliente, 13, '*') AS "RUT",
       INITCAP(nombre) AS "Cliente",
       NVL(TO_CHAR(telefono), 'Sin teléfono') AS "TELÉFONO",
       NVL(TO_CHAR(codcomuna), 'Sin comuna') AS "COMUNA",
       estado AS "ESTADO",
      CASE
         WHEN saldo / credito < 0.5 THEN
        'Bueno (' || TO_CHAR(credito - saldo, 'FM$999G999G999') || ')'
        WHEN saldo / credito BETWEEN 0.5 AND 0.8 THEN
        'Regular (' || TO_CHAR(saldo, 'FM$999G999G999') || ')'
        ELSE
        'Crítico'
      END AS "Estado Crédito",
      NVL(
         SUBSTR(mail, INSTR(mail, '@') + 1),
         'Correo no registrado'
         ) AS "Dominio Correo"  
FROM cliente
WHERE estado = 'A'
  AND credito > 0
ORDER BY nombre ASC;

/* =====================================================
   CASO 3 - STOCK DE PRODUCTOS
   ===================================================== */
   
SELECT codproducto AS "ID",
       INITCAP(descripcion) AS "Descripción de Producto",
       CASE
           WHEN valorcompradolar IS NULL THEN 'Sin registro'
           ELSE TO_CHAR(valorcompradolar, 'FM999G999D99') || ' USD'
       END AS "Compra en USD",
       CASE
           WHEN valorcompradolar IS NULL THEN 'Sin registro'
           ELSE TO_CHAR(valorcompradolar * &TIPOCAMBIO_DOLAR,
                        'FM$999G999G999') || ' PESOS'
       END AS "USD convertido",
       totalstock AS "Stock",
       CASE
           WHEN totalstock IS NULL THEN 'Sin datos'
           WHEN totalstock < &UMBRAL_BAJO THEN '¡ALERTA stock muy bajo!'
           WHEN totalstock BETWEEN &UMBRAL_BAJO AND &UMBRAL_ALTO THEN '¡Reabastecer pronto!'
           ELSE 'OK'
       END AS "Alerta Stock",
       CASE
           WHEN totalstock > 80 THEN
               TO_CHAR(vunitario * 0.90, 'FM$999G999G999')
           ELSE 'N/A'
       END AS "Precio Oferta"
FROM producto
WHERE LOWER(descripcion) LIKE '%zapato%'
  AND LOWER(procedencia) = 'i'
ORDER BY codproducto DESC;