
    --Пример условия фильтрации:

--sql

SELECT * FROM koroleva_d.пациенты WHERE возраст > 30;

    --Пример объединения наборов данных (перекрёстное):

--sql

SELECT koroleva_d.пациенты.*, koroleva_d.история_болезни.*
FROM koroleva_d.пациенты CROSS JOIN koroleva_d.история_болезни;

    --Пример объединения наборов данных (внутреннее):

--sql

SELECT koroleva_d.пациенты.*, koroleva_d.история_болезни.*
FROM koroleva_d.пациенты INNER JOIN koroleva_d.история_болезни ON koroleva_d.пациенты.id = koroleva_d.история_болезни.пациент;

    --Пример объединения наборов данных (внешнее):

--sql

SELECT koroleva_d.пациенты.*, koroleva_d.история_болезни.*
FROM koroleva_d.пациенты LEFT JOIN koroleva_d.история_болезни ON koroleva_d.пациенты.id = koroleva_d.история_болезни.пациент;

    --Пример использования функции агрегирования и группировки записей:

--sql

SELECT COUNT(*), диагноз
FROM koroleva_d.история_болезни
GROUP BY диагноз;

    --Пример сортировки записей:

--sql

SELECT * FROM koroleva_d.пациенты ORDER BY возраст DESC;

    --Пример выборки записей в заданном интервале:

--sql

SELECT * FROM koroleva_d.история_болезни WHERE дата_заболевания BETWEEN '2022-01-01' AND '2022-12-31';

    --Пример исключения дубликатов:

--sql

SELECT DISTINCT город FROM пациенты;

    --Пример соединения наборов записей (объединение):

--sql

SELECT * FROM koroleva_d.пациенты
UNION
SELECT * FROM koroleva_d.врачи;

    --Пример соединения наборов записей (пересечение):

--sql

SELECT * FROM koroleva_d.пациенты
INTERSECT
SELECT * FROM koroleva_d.врачи;

    --Пример соединения наборов записей (исключение):

--sql

SELECT * FROM koroleva_d.пациенты
EXCEPT
SELECT * FROM koroleva_d.врачи;

    --Пример вложенного подзапроса:

--sql

SELECT *
FROM koroleva_d.пациенты
WHERE id IN (
    SELECT пациент
    FROM koroleva_d.история_болезни
    WHERE диагноз = (
        SELECT id
        FROM диагнозы
        WHERE название_диагноза = 'Грипп'
    )
);
