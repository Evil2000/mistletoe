/*
Auswertung Minuten pro Monat in welche Netze
*/
SELECT
	CONCAT( YEAR( `datetime` ) , '-', MONTH( `datetime` )) AS Monat,
	SUM(`duration`)/ 60 AS Minuten,
	CASE
		WHEN `to_orig` REGEXP '^00' THEN 'Ausland'
		WHEN `to_orig` REGEXP '^0137[1-5]' THEN 'T-VoteCall'
		WHEN `to_orig` REGEXP '^0137[6-9]' THEN 'T-VoteCall 2'
		WHEN `to_orig` REGEXP '^016[489]([2-9]|[0-1]|5[1-2])' THEN 'Cityruf'
		WHEN `to_orig` REGEXP '^01[5-7]' THEN 'Mobil'
		WHEN `to_orig` REGEXP '^01801' THEN 'Sonderrufnummer 01801'
		WHEN `to_orig` REGEXP '^01802' THEN 'Sonderrufnummer 01802'
		WHEN `to_orig` REGEXP '^01803' THEN 'Sonderrufnummer 01803'
		WHEN `to_orig` REGEXP '^01804' THEN 'Sonderrufnummer 01804'
		WHEN `to_orig` REGEXP '^01805' THEN 'Sonderrufnummer 01805'
		WHEN `to_orig` REGEXP '^01806' THEN 'Sonderrufnummer 01806'
		WHEN `to_orig` REGEXP '^01807' THEN 'Sonderrufnummer 01807'
		WHEN `to_orig` REGEXP '^019' THEN 'Sonderrufnummer 019x'
		WHEN `to_orig` REGEXP '^032' THEN 'National Sonder'
		WHEN `to_orig` REGEXP '^0800' THEN 'Kostenlos'
		WHEN `to_orig` REGEXP '^0900' THEN 'Sonderrufnummer'
		WHEN `to_orig` REGEXP '^(0[2-9]|[^0])' THEN 'Festnetz'
		ELSE 'Unbekannt'
	END AS Ziel
FROM
	`callog`
WHERE
	`direction` < 3
	AND `duration` > 0
GROUP BY
	`Monat`,
	`Ziel`;