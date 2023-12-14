
   -- Триггер на событие удаления, реализующий каскадное удаление строк в дочерних таблицах:

--sql

-- Создание триггера
CREATE OR REPLACE FUNCTION koroleva_d.каскадное_удаление_строк()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM koroleva_d.история_болезни WHERE пациент = OLD.id;
    -- Добавьте здесь код удаления строк из других дочерних таблиц, если такие есть

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER koroleva_d.удаление_отделения
    BEFORE DELETE ON koroleva_d.отделения
    FOR EACH ROW
    EXECUTE FUNCTION koroleva_d.каскадное_удаление_строк();

--    Триггер на событие вставки, реализующий проверку не пустых значений, вставляющий текущие значения даты и значения по умолчанию:

--sql

-- Создание триггера
CREATE OR REPLACE FUNCTION koroleva_d.проверка_вставки()
RETURNS TRIGGER AS $$
BEGIN
    IF koroleva_d.NEW.название_отделения IS NULL OR koroleva_d.NEW.название_отделения = '' THEN
        RAISE EXCEPTION 'Название отделения должно быть указано';
    END IF;

    IF NEW.этаж IS NULL OR NEW.этаж <= 0 THEN
        RAISE EXCEPTION 'Этаж должен быть положительным числом';
    END IF;

    IF NEW.номера_кабинетов IS NULL OR NEW.номера_кабинетов = '' THEN
        RAISE EXCEPTION 'Номера кабинетов должны быть указаны';
    END IF;

    IF NEW.ФИО_заведующего IS NULL OR NEW.ФИО_заведующего = '' THEN
        RAISE EXCEPTION 'ФИО заведующего должно быть указано';
    END IF;

    NEW.дата_вставки := CURRENT_DATE;
    -- Добавьте здесь код для установки значений по умолчанию для других полей, если такие есть

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER koroleva_d.вставка_отделения
    BEFORE INSERT ON koroleva_d.отделения
    FOR EACH ROW
    EXECUTE FUNCTION koroleva_d.проверка_вставки();

--    Триггер на событие обновления, не разрешающий вставлять некорректные значения в поля таблицы:

--sql

-- Создание триггера
CREATE OR REPLACE FUNCTION koroleva_d.проверка_обновления()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.название_отделения IS NULL OR NEW.название_отделения = '' THEN
        RAISE EXCEPTION 'Название отделения должно быть указано';
    END IF;

    IF NEW.этаж IS NULL OR NEW.этаж <= 0 THEN
        RAISE EXCEPTION 'Этаж должен быть положительным числом';
    END IF;

    IF NEW.номера_кабинетов IS NULL OR NEW.номера_кабинетов = '' THEN
        RAISE EXCEPTION 'Номера кабинетов должны быть указаны';
    END IF;

    IF NEW.ФИО_заведующего IS NULL OR NEW.ФИО_заведующего = '' THEN
        RAISE EXCEPTION 'ФИО заведующего должно быть указано';
    END IF;

    -- Добавьте здесь код для проверки и обновления других полей, если такие есть

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER koroleva_d.обновление_отделения
    BEFORE UPDATE ON koroleva_d.отделения
    FOR EACH ROW
    EXECUTE FUNCTION koroleva_d.проверка_обновления();



--    Триггер для аудита действий пользователя, записывающий информацию о том, кто, когда и какое действие выполнил, а также о старых и новых значениях:

--sql

-- Создание таблицы для хранения аудита
CREATE TABLE koroleva_d.аудит_действий (
    id SERIAL PRIMARY KEY,
    таблица VARCHAR(255),
    действие VARCHAR(255),
    пользователь VARCHAR(255),
    дата_действия TIMESTAMP,
    старые_значения JSONB,
    новые_значения JSONB
);

-- Создание триггера
CREATE OR REPLACE FUNCTION koroleva_d.аудит_действий()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO koroleva_d.аудит_действий (таблица, действие, пользователь, дата_действия, новые_значения)
        VALUES (TG_TABLE_NAME, 'INSERT', current_user, current_timestamp, to_jsonb(NEW));
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO koroleva_d.аудит_действий (таблица, действие, пользователь, дата_действия, старые_значения, новые_значения)
        VALUES (TG_TABLE_NAME, 'UPDATE', current_user, current_timestamp, to_jsonb(OLD), to_jsonb(NEW));
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO koroleva_d.аудит_действий (таблица, действие, пользователь, дата_действия, старые_значения)
        VALUES (TG_TABLE_NAME, 'DELETE', current_user, current_timestamp, to_jsonb(OLD));
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Создание триггера на каждую нужную таблицу
CREATE TRIGGER koroleva_d.аудит_отделений
    AFTER INSERT OR UPDATE OR DELETE ON koroleva_d.отделения
    FOR EACH ROW
    EXECUTE FUNCTION koroleva_d.аудит_действий();
