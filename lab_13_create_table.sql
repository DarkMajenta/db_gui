-- Описание таблицы "отделения"
CREATE TABLE koroleva_d.отделения (
  id SERIAL PRIMARY KEY,
  название_отделения VARCHAR(255) NOT NULL,
  этаж INTEGER NOT NULL,
  номера_кабинетов VARCHAR(255) NOT NULL,
  ФИО_заведующего VARCHAR(255) NOT NULL,
  CONSTRAINT отделения_проверка_этаж CHECK (этаж > 0) -- Ограничение проверки: этаж должен быть положительным числом
);

COMMENT ON COLUMN koroleva_d.отделения.id IS 'Уникальный идентификатор отделения';
COMMENT ON COLUMN koroleva_d.отделения.название_отделения IS 'Название отделения';
COMMENT ON COLUMN koroleva_d.отделения.этаж IS 'Этаж, на котором расположено отделение';
COMMENT ON COLUMN koroleva_d.отделения.номера_кабинетов IS 'Номера кабинетов в отделении';
COMMENT ON COLUMN koroleva_d.отделения.ФИО_заведующего IS 'ФИО заведующего отделением';

-- Описание таблицы "врачи"
CREATE TABLE koroleva_d.врачи (
  id SERIAL PRIMARY KEY,
  фамилия VARCHAR(255) NOT NULL,
  имя VARCHAR(255) NOT NULL,
  отчество VARCHAR(255) NOT NULL,
  должность VARCHAR(255) NOT NULL,
  стаж_работы INTEGER NOT NULL,
  научное_звание VARCHAR(255),
  адрес VARCHAR(255) NOT NULL,
  номер_отделения INTEGER REFERENCES koroleva_d.отделения(id) NOT NULL,
  CONSTRAINT врачи_проверка_стаж CHECK (стаж_работы >= 0) -- Ограничение проверки: стаж работы должен быть неотрицательным числом
);

COMMENT ON COLUMN koroleva_d.врачи.id IS 'Уникальный идентификатор врача';
COMMENT ON COLUMN koroleva_d.врачи.фамилия IS 'Фамилия врача';
COMMENT ON COLUMN koroleva_d.врачи.имя IS 'Имя врача';
COMMENT ON COLUMN koroleva_d.врачи.отчество IS 'Отчество врача';
COMMENT ON COLUMN koroleva_d.врачи.должность IS 'Должность врача';
COMMENT ON COLUMN koroleva_d.врачи.стаж_работы IS 'Стаж работы врача в годах';
COMMENT ON COLUMN koroleva_d.врачи.научное_звание IS 'Научное звание врача (необязательно)';
COMMENT ON COLUMN koroleva_d.врачи.адрес IS 'Адрес врача';
COMMENT ON COLUMN koroleva_d.врачи.номер_отделения IS 'Уникальный идентификатор отделения, в котором работает врач';

-- Описание таблицы "пациенты"
CREATE TABLE koroleva_d.пациенты (
  id SERIAL PRIMARY KEY,
  фамилия VARCHAR(255) NOT NULL,
  имя VARCHAR(255) NOT NULL,
  отчество VARCHAR(255) NOT NULL,
  адрес VARCHAR(255) NOT NULL,
  город VARCHAR(255) NOT NULL,
  возраст INTEGER NOT NULL,
  пол VARCHAR(255) NOT NULL,
  CONSTRAINT пациенты_проверка_возраст CHECK (возраст > 0) -- Ограничение проверки: возраст должен быть положительным числом
);

COMMENT ON COLUMN koroleva_d.пациенты.id IS 'Уникальный идентификатор пациента';
COMMENT ON COLUMN koroleva_d.пациенты.фамилия IS 'Фамилия пациента';
COMMENT ON COLUMN koroleva_d.пациенты.имя IS 'Имя пациента';
COMMENT ON COLUMN koroleva_d.пациенты.отчество IS 'Отчество пациента';
COMMENT ON COLUMN koroleva_d.пациенты.адрес IS 'Адрес пациента';
COMMENT ON COLUMN koroleva_d.пациенты.город IS 'Город проживания пациента';
COMMENT ON COLUMN koroleva_d.пациенты.возраст IS 'Возраст пациента в годах';
COMMENT ON COLUMN koroleva_d.пациенты.пол IS 'Пол пациента (мужской или женский)';

-- Описание таблицы "диагнозы"
CREATE TABLE koroleva_d.диагнозы (
  id SERIAL PRIMARY KEY,
  название_диагноза VARCHAR(255) NOT NULL,
  признаки_болезни VARCHAR(255) NOT NULL,
  период_лечения VARCHAR(255) NOT NULL,
  назначения VARCHAR(255) NOT NULL
);

COMMENT ON COLUMN koroleva_d.диагнозы.id IS 'Уникальный идентификатор диагноза';
COMMENT ON COLUMN koroleva_d.диагнозы.название_диагноза IS 'Название диагноза';
COMMENT ON COLUMN koroleva_d.диагнозы.признаки_болезни IS 'Признаки болезни, связанные с диагнозом';
COMMENT ON COLUMN koroleva_d.диагнозы.период_лечения IS 'Период лечения для данного диагноза';
COMMENT ON COLUMN koroleva_d.диагнозы.назначения IS 'Назначения для лечения данного диагноза';

-- Описание таблицы "история_болезни"
CREATE TABLE koroleva_d.история_болезни (
  id SERIAL PRIMARY KEY,
  пациент INTEGER REFERENCES koroleva_d.пациенты(id) NOT NULL,
  врач INTEGER REFERENCES koroleva_d.врачи(id) NOT NULL,
  диагноз INTEGER REFERENCES koroleva_d.диагнозы(id) NOT NULL,
  лечение VARCHAR(255) NOT NULL,
  дата_заболевания DATE NOT NULL,
  дата_излечения DATE NOT NULL,
  вид_лечения VARCHAR(255) NOT NULL
);

COMMENT ON COLUMN koroleva_d.история_болезни.id IS 'Уникальный идентификатор записи об истории болезни';
COMMENT ON COLUMN koroleva_d.история_болезни.пациент IS 'Уникальный идентификатор пациента';
COMMENT ON COLUMN koroleva_d.история_болезни.врач IS 'Уникальный идентификатор врача';
COMMENT ON COLUMN koroleva_d.история_болезни.диагноз IS 'Уникальный идентификатор диагноза';
COMMENT ON COLUMN koroleva_d.история_болезни.лечение IS 'Описание лечения';
COMMENT ON COLUMN koroleva_d.история_болезни.дата_заболевания IS 'Дата начала заболевания';
COMMENT ON COLUMN koroleva_d.история_болезни.дата_излечения IS 'Дата излечения';
COMMENT ON COLUMN koroleva_d.история_болезни.вид_лечения IS 'Вид лечения';

-- Ограничение проверки для поля "этаж"
ALTER TABLE koroleva_d.отделения
  ADD CONSTRAINT проверка_этажа CHECK (этаж > 0);

-- Ограничение проверки для поля "номера_кабинетов"
ALTER TABLE koroleva_d.отделения
  ADD CONSTRAINT проверка_номеров_кабинетов CHECK (номера_кабинетов <> '');

-- Заполнение таблицы "отделения"
INSERT INTO koroleva_d.отделения (название_отделения, этаж, номера_кабинетов, ФИО_заведующего)
SELECT
  'Отделение ' || generate_series,
  floor(random() * 10) + 1,
  'Кабинет ' || ((generate_series % 5) + 1)::text || ', ' || ((generate_series % 5) + 6)::text,
  'Заведующий ' || generate_series
FROM generate_series(1, 10);

-- Заполнение таблицы "врачи"
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

-- Заполнение таблицы "пациенты"
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

-- Заполнение таблицы "диагнозы"
INSERT INTO koroleva_d.диагнозы (название_диагноза, признаки_болезни, период_лечения, назначения)
SELECT
  'Диагноз ' || generate_series,
  'Признаки болезни ' || generate_series,
  'Период лечения ' || generate_series,
  'Назначения ' || generate_series
FROM generate_series(1, 10);

-- Заполнение таблицы "история_болезни"
INSERT INTO koroleva_d.история_болезни (пациент, врач, диагноз, лечение, дата_заболевания, дата_излечения, вид_лечения)
SELECT
  (floor(random() * 30) + 1),
  (floor(random() * 20) + 1),
  (floor(random() * 10) + 1),
  'Лечение ' || generate_series,
  current_date - INTERVAL '1 day' * (floor(random() * 365) + 1),
  current_date,
  'Вид лечения ' || generate_series
FROM generate_series(1, 50);
