--Задание 1: Создание функции для определения статистических показателей

--sql

CREATE OR REPLACE FUNCTION koroleva_d.get_statistic_value(column_name varchar)
RETURNS TABLE (min_value numeric, max_value numeric, avg_value numeric)
AS $$
BEGIN
  EXECUTE format('SELECT
                    MIN(%I),
                    MAX(%I),
                    AVG(%I)
                  FROM
                    koroleva_d.отделения', column_name, column_name, column_name)
  INTO min_value, max_value, avg_value;

  RETURN;
END;
$$ LANGUAGE plpgsql;

--Задание 2: Создание функции для поиска в таблице по части фразы

--sql

CREATE OR REPLACE FUNCTION koroleva_d.search_table_data(search_phrase text)
RETURNS TABLE (id integer, название_отделения varchar, этаж integer, номера_кабинетов varchar, ФИО_заведующего varchar)
AS $$
BEGIN
  RETURN QUERY
    SELECT
      id, название_отделения, этаж, номера_кабинетов, ФИО_заведующего
    FROM
      koroleva_d.отделения
    WHERE
      название_отделения ILIKE '%' || search_phrase || '%' OR
      номера_кабинетов ILIKE '%' || search_phrase || '%' OR
      ФИО_заведующего ILIKE '%' || search_phrase || '%';
END;
$$ LANGUAGE plpgsql;

--Задание 3: Создание функции для конкатенации полей таблиц

--sql

CREATE OR REPLACE FUNCTION koroleva_d.concatenate_fields()
RETURNS TABLE (id integer, concatenated_fields varchar)
AS $$
BEGIN
  RETURN QUERY
    SELECT
      id, название_отделения || ' ' || номера_кабинетов || ' ' || ФИО_заведующего
    FROM
      koroleva_d.отделения;
END;
$$ LANGUAGE plpgsql;

--Задание 4: Создание функции для определения доли указанного значения поля таблицы

--sql

CREATE OR REPLACE FUNCTION koroleva_d.calculate_field_fraction(field_value integer)
RETURNS numeric
AS $$
DECLARE
  total_count integer;
  field_count integer;
BEGIN
  SELECT COUNT(*) INTO total_count FROM koroleva_d.пациенты;
  EXECUTE format('SELECT COUNT(*) FROM koroleva_d.пациенты WHERE возраст = %s', field_value) INTO field_count;

  IF total_count = 0 THEN
    RETURN 0;
  ELSE
    RETURN field_count::numeric / total_count::numeric;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION koroleva_d.insert_отделения()
RETURNS VOID AS $$
BEGIN
  INSERT INTO koroleva_d.отделения (название_отделения, этаж, номера_кабинетов, ФИО_заведующего)
  SELECT
    'Отделение ' || generate_series,
    floor(random() * 10) + 1,
    'Кабинет ' || ((generate_series % 5) + 1)::text || ', ' || ((generate_series % 5) + 6)::text,
    'Заведующий ' || generate_series
  FROM generate_series(1, 10);

  RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION koroleva_d.insert_врачи()
RETURNS VOID AS $$
BEGIN
  INSERT INTO koroleva_d.врачи (фамилия, имя, отчество, должность, стаж_работы, научное_звание, адрес, номер_отделения)
  SELECT
    'Фамилия ' || generate_series,
    'Имя ' || generate_series,
    'Отчество ' || generate_series,
    'Должность ' || generate_series,
    floor(random() * 20) + 1,
    CASE WHEN random() < 0.3 THEN 'Научное звание ' || generate_series ELSE NULL END,
    'Адрес ' || generate_series,
    (floor(random() * 10) + 1)
  FROM generate_series(1, 20);

  RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION koroleva_d.insert_пациенты()
RETURNS VOID AS $$
BEGIN
  INSERT INTO koroleva_d.пациенты (фамилия, имя, отчество, адрес, город, возраст, пол)
  SELECT
    'Фамилия ' || generate_series,
    'Имя ' || generate_series,
    'Отчество ' || generate_series,
    'Адрес ' || generate_series,
    'Город ' || generate_series,
    floor(random() * 70) + 18,
    CASE WHEN random() < 0.5 THEN 'Мужской' ELSE 'Женский' END
  FROM generate_series(1, 30);

  RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION koroleva_d.insert_диагнозы()
RETURNS VOID AS $$
BEGIN
  INSERT INTO koroleva_d.диагнозы (название_диагноза, признаки_болезни, период_лечения, назначения)
  SELECT
    'Диагноз ' || generate_series,
    'Признаки болезни ' || generate_series,
    'Период лечения ' || generate_series,
    'Назначения ' || generate_series
  FROM generate_series(1, 10);

  RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_история_болезни()
RETURNS VOID AS $$
BEGIN
  INSERT INTO история_болезни (пациент, врач, диагноз, лечение, дата_заболевания, дата_излечения, вид_лечения)
  SELECT
    (floor(random() * 30) + 1),
    (floor(random() * 20) + 1),
    (floor(random() * 10) + 1),
    'Лечение ' || generate_series,
    current_date - INTERVAL '1 day' * (floor(random() * 365) + 1),
    current_date,
    'Вид лечения ' || generate_series
  FROM generate_series(1, 50);

  RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION koroleva_d.delete_история_болезни()
RETURNS VOID AS $$
BEGIN
  DELETE FROM koroleva_d.история_болезни;

  RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION koroleva_d.delete_диагнозы()
RETURNS VOID AS $$
BEGIN
  DELETE FROM koroleva_d.диагнозы;

  RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION koroleva_d.delete_пациенты()
RETURNS VOID AS $$
BEGIN
  DELETE FROM koroleva_d.пациенты;

  RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION koroleva_d.delete_врачи()
RETURNS VOID AS $$
BEGIN
  DELETE FROM koroleva_d.врачи;

  RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION koroleva_d.delete_отделения()
RETURNS VOID AS $$
BEGIN
  DELETE FROM koroleva_d.отделения;

  RETURN;
END;
$$ LANGUAGE plpgsql;

