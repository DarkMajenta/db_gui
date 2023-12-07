import wx
import psycopg2
import wx.grid as gridlib

# Создание подключения к базе данных
conn = psycopg2.connect(database="rpr", user="your_username", password="your_password",
                        host="your_host", port="your_port")


class TableFrame(wx.Frame):
    def __init__(self, parent, title, table_name):
        super(TableFrame, self).__init__(parent, title=title, size=(600, 400))
        self.table_name = table_name
        self.connection = conn
        self.cursor = self.connection.cursor()

        # Создание таблицы для отображения записей
        self.grid = gridlib.Grid(self)
        self.grid.CreateGrid(0, 0)

        # Добавление кнопок
        self.add_button = wx.Button(self, label="Добавить")
        self.edit_button = wx.Button(self, label="Изменить")
        self.delete_button = wx.Button(self, label="Удалить")

        # Упаковка элементов
        sizer = wx.BoxSizer(wx.VERTICAL)
        sizer.Add(self.grid, 1, wx.EXPAND)
        sizer.Add(self.add_button, 0, wx.ALL, 5)
        sizer.Add(self.edit_button, 0, wx.ALL, 5)
        sizer.Add(self.delete_button, 0, wx.ALL, 5)
        self.SetSizer(sizer)

        # Привязка обработчиков событий к кнопкам
        self.add_button.Bind(wx.EVT_BUTTON, self.on_add_button)
        self.edit_button.Bind(wx.EVT_BUTTON, self.on_edit_button)
        self.delete_button.Bind(wx.EVT_BUTTON, self.on_delete_button)

        # Заполнение таблицы
        self.load_data()

    def load_data(self):
        self.cursor.execute(f"SELECT * FROM {self.table_name}")
        rows = self.cursor.fetchall()
        columns = [desc[0] for desc in self.cursor.description]

        # Очистка таблицы перед загрузкой данных
        self.grid.ClearGrid()

        # Задание количества строк и столбцов в таблице
        self.grid.SetTableSize(len(rows), len(columns))

        # Задание названий столбцов
        for col, column_name in enumerate(columns):
            self.grid.SetColLabelValue(col, column_name)

        # Заполнение ячеек значениями
        for row, data in enumerate(rows):
            for col, value in enumerate(data):
                self.grid.SetCellValue(row, col, str(value))

    def on_add_button(self, event):
        # Добавление записи
        # Откройте новое окно или диалог для ввода данных записи
        dialog = wx.TextEntryDialog(self, "Введите данные для добавления записи:", "Добавление записи")
        if dialog.ShowModal() == wx.ID_OK:
            input_data = dialog.GetValue()
            # Выполнение INSERT-запроса к базе данных
            sql = f"INSERT INTO {self.table_name} VALUES ({input_data})"
            self.cursor.execute(sql)
            self.connection.commit()
            # Обновление таблицы
            self.load_data()
        dialog.Destroy()

    def on_edit_button(self, event):
        # Изменение записи
        selected_row = self.grid.GetSelectedRows()
        if selected_row:
            row_data = []
            for col in range(self.grid.GetNumberCols()):
                value = self.grid.GetCellValue(selected_row[0], col)
                row_data.append(value)

            # Откройте новое окно или диалог для изменения данных записи
            dialog = wx.TextEntryDialog(self, "Введите новые данные для изменения записи:", "Изменение записи")
            if dialog.ShowModal() == wx.ID_OK:
                input_data = dialog.GetValue()
                # Выполнение UPDATE-запроса к базе данных
                set_values = []
                for col, value in enumerate(input_data):
                    set_values.append(f"{self.grid.GetColLabelValue(col)} = {value}")

                sql = f"UPDATE {self.table_name} SET {', '.join(set_values)} WHERE id = {row_data[0]}"
                self.cursor.execute(sql)
                self.connection.commit()
                # Обновление таблицы
                self.load_data()
            dialog.Destroy()
        else:
            wx.MessageBox("Пожалуйста, выберите запись для изменения.", "Ошибка", wx.OK | wx.ICON_ERROR)

    def on_delete_button(self, event):
        # Удаление записи
        selected_row = self.grid.GetSelectedRows()
        if selected_row:
            row_data = []
            for col in range(self.grid.GetNumberCols()):
                value = self.grid.GetCellValue(selected_row[0], col)
                row_data.append(value)

            # Выполнение DELETE-запроса к базе данных
            sql = f"DELETE FROM {self.table_name} WHERE id = {row_data[0]}"
            self.cursor.execute(sql)
            self.connection.commit()
            # Обновление таблицы
            self.load_data()
        else:
            wx.MessageBox("Пожалуйста, выберите запись для удаления.", "Ошибка", wx.OK | wx.ICON_ERROR)


# Создание и запуск приложения
app = wx.App()
departments_frame = TableFrame(None, "Таблица отделения", "отделения")
departments_frame.Show()

employees_frame = TableFrame(None, "Таблица сотрудники", "врачи")
employees_frame.Show()

table_frame = TableFrame(None, "Таблица пациенты", "пациенты")
table_frame.Show()

table_frame = TableFrame(None, "Таблица диагнозы", "диагнозы")
table_frame.Show()

table_frame = TableFrame(None, "Таблица история болезни", "история_болезни")
table_frame.Show()


app.MainLoop()
