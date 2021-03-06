CREATE TABLE CHURN AS
	(SELECT CUSTOMER_ID,
			FIRST_ORDER_DATE,
			LAST_ORDER_DATE,
			AVG_DAYS_BETWEEN_SHOP,
			MAX_ORDER_DATE,
			DAYS_SINCE_LAST_SHOP,
			AVG_DAYS_BETWEEN_SHOP * 3 AS CHURN_THRESHOLD,
			TOTAL_ORDERS,
			CASE
							WHEN DAYS_SINCE_LAST_SHOP > (AVG_DAYS_BETWEEN_SHOP * 3) THEN 'Y'
							WHEN DAYS_SINCE_LAST_SHOP <= (AVG_DAYS_BETWEEN_SHOP * 3) THEN 'N'
							ELSE NULL
			END AS CHURNED
		FROM
			(SELECT CUSTOMER_ID,
					MIN(ORDER_DATE) AS FIRST_ORDER_DATE,
					MAX(ORDER_DATE) AS LAST_ORDER_DATE,
					CASE
									WHEN COUNT(DATE_DIFF) = 0 THEN 0
									ELSE AVG(DATE_DIFF)
					END AS AVG_DAYS_BETWEEN_SHOP,
					MAX(MAX_ORDER_DATE) AS MAX_ORDER_DATE,
					MAX(MAX_ORDER_DATE) - MAX(ORDER_DATE) AS DAYS_SINCE_LAST_SHOP,
					COUNT(ORDER_DATE) AS TOTAL_ORDERS
				FROM
					(SELECT CUSTOMER_ID,
							ORDER_DATE,
							ORDER_DATE_ABOVE,
							ORDER_DATE - ORDER_DATE_ABOVE AS DATE_DIFF,
							MAX_ORDER_DATE
						FROM
							(SELECT CUSTOMER_ID,
									ORDER_DATE,
									LAG(ORDER_DATE,

										1) OVER(PARTITION BY CUSTOMER_ID
																		ORDER BY CUSTOMER_ID,

														ORDER_DATE) AS ORDER_DATE_ABOVE,
									MAX_ORDER_DATE
								FROM
									(SELECT DISTINCT CUSTOMER_ID,
											ORDER_DATE,

											(SELECT MAX(ORDER_DATE)
												FROM CUSTOMER_ORDER) AS MAX_ORDER_DATE
										FROM CUSTOMER_ORDER
										ORDER BY CUSTOMER_ID,
											ORDER_DATE) AS X) AS Y) AS Z
				GROUP BY CUSTOMER_ID) AS XY);