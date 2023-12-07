import psycopg2

# Функция для подключения к базе данных
def connect():
    conn = psycopg2.connect(
        dbname="your_db_name",
        user="your_username",
        password="your_password",
        host="your_host",
        port="your_port"
    )
    return conn

# Функция для просмотра данных из таблицы "отделения"
def view_departments():
    conn = connect()
    cursor = conn.cursor()

    cursor.callproc("просмотр_отделений")
    results = cursor.fetchall()

    if len(results) > 0:
        for row in results:
            print(f"ID: {row[0]}")
            print(f"Название отделения: {row[1]}")
            print(f"Этаж: {row[2]}")
            print(f"Номера кабинетов: {row[3]}")
            print(f"ФИО заведующего: {row[4]}")
            print("------------------------")
    else:
        print("Нет данных в таблице 'отделения'")

    cursor.close()
    conn.close()

# Функция для добавления записи в таблицу "отделения"
def add_department():
    conn = connect()
    cursor = conn.cursor()

    name = input("Введите название отделения: ")
    floor = int(input("Введите этаж: "))
    rooms = input("Введите номера кабинетов: ")
    head = input("Введите ФИО заведующего: ")

    cursor.callproc("добавление_отделения", (name, floor, rooms, head))
    conn.commit()

    print("Запись успешно добавлена в таблицу 'отделения'")

    cursor.close()
    conn.close()

# Функция для изменения записи в таблице "отделения"
def update_department():
    conn = connect()
    cursor = conn.cursor()

    department_id = int(input("Введите ID отделения для изменения: "))

    cursor.callproc("просмотр_отделения", (department_id,))
    result = cursor.fetchone()

    if result is not None:
        print(f"Найдена запись с ID: {result[0]}")
        print(f"Название отделения: {result[1]}")
        print(f"Этаж: {result[2]}")
        print(f"Номера кабинетов: {result[3]}")
        print(f"ФИО заведующего: {result[4]}")

        name = input("Введите новое название отделения: ")
        floor = int(input("Введите новый этаж: "))
        rooms = input("Введите новые номера кабинетов: ")
        head = input("Введите новое ФИО заведующего: ")

        cursor.callproc("обновление_отделения", (department_id, name, floor, rooms, head))
        conn.commit()

        print("Запись успешно обновлена в таблице 'отделения'")
    else:
        print("Запись с указанным ID отделения не найдена.")

    cursor.close()
    conn.close()

# Главная функция для выбора действий
def main():
    while True:
        print("Выберите действие:")
        print("1. Просмотреть отделения")
        print("2. Добавить отделение")
        print("3. Изменить отделение")
        print("4. Выход")

        choice = input("Введите номер действия: ")

        if choice == "1":
            view_departments()
        elif choice == "2":
            add_department()
        elif choice == "3":
            update_department()
        elif choice == "4":
            print("До свидания!")
            break
        else:
            print("Некорректный выбор. Попробуйте еще раз.")

# Запуск главной функции
main()
