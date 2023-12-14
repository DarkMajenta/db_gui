# установи зависимости
# pip install -U psycopg2 wxPython

import wx
import psycopg2
import wx.MessageBox as MessageBox
import random
from datetime import date, timedelta

class MainFrame(wx.Frame):
    def __init__(self, parent, title):
        super(MainFrame, self).__init__(parent, title=title, size=(400, 200))

        panel = wx.Panel(self)

        # Создание и размещение элементов управления
        host_label = wx.StaticText(panel, label="Хост:")
        self.host_text = wx.TextCtrl(panel)

        user_label = wx.StaticText(panel, label="Пользователь:")
        self.user_text = wx.TextCtrl(panel)

        password_label = wx.StaticText(panel, label="Пароль:")
        self.password_text = wx.TextCtrl(panel, style=wx.TE_PASSWORD)

        db_label = wx.StaticText(panel, label="Имя базы данных:")
        self.db_text = wx.TextCtrl(panel)

        connect_button = wx.Button(panel, label="Подключиться")
        connect_button.Bind(wx.EVT_BUTTON, self.on_connect)

        # Размещение элементов управления с использованием гибкой сетки (wx.FlexGridSizer)
        sizer = wx.FlexGridSizer(cols=2, hgap=10, vgap=10)
        sizer.AddMany([(host_label), (self.host_text, 1, wx.EXPAND),
                       (user_label), (self.user_text, 1, wx.EXPAND),
                       (password_label), (self.password_text, 1, wx.EXPAND),
                       (db_label), (self.db_text, 1, wx.EXPAND),
                       (connect_button, 1, wx.EXPAND)])
        panel.SetSizer(sizer)

    def on_connect(self, event):
        host = self.host_text.GetValue()
        user = self.user_text.GetValue()
        password = self.password_text.GetValue()
        db_name = self.db_text.GetValue()

        try:
            # Установка соединения с базой данных
            conn = psycopg2.connect(host=host, user=user, password=password, dbname=db_name)

            # Создание курсора для выполнения SQL-запросов
            cursor = conn.cursor()

            # Пример выполнения SQL-запроса для проверки успешного подключения
            cursor.execute("SELECT version();")
            db_version = cursor.fetchone()[0]
            print(f"Connected to the database. Database version: {db_version}")

            # Здесь можно добавить код для выполнения других операций с базой данных

            # Закрытие курсора и соединения с базой данных
            cursor.close()
            conn.close()

            # Отображение второго окна после успешного подключения
            second_frame = SecondFrame(self)
            second_frame.Show()
            self.Hide()

        except (psycopg2.Error, Exception) as e:
            print(f"Error connecting to the database: {e}")
            # Обработка ошибки подключения к базе данных, например, отображение сообщения об ошибке
            wx.MessageBox("Error connecting to the database. Please check your connection details.", "Error",
                            wx.OK | wx.ICON_ERROR)

class TableWindow(wx.Panel):
    def __init__(self, parent, title, table_name, previous_panel):
        wx.Panel.__init__(self, parent)

        # Создаем кнопку для возврата на второе окно
        back_button = wx.Button(self, label="Назад")
        back_button.Bind(wx.EVT_BUTTON, self.on_back_button_click)

        # Создаем кнопки для доступных действий
        add_button = wx.Button(self, label="Добавить запись")
        add_button.Bind(wx.EVT_BUTTON, self.on_add_button_click)
        delete_button = wx.Button(self, label="Удалить запись")
        delete_button.Bind(wx.EVT_BUTTON, self.on_delete_button_click)
        edit_button = wx.Button(self, label="Изменить запись")
        edit_button.Bind(wx.EVT_BUTTON, self.on_edit_button_click)

        # Создаем текстовое поле для отображения имени выбранной таблицы
        text = wx.StaticText(self, label=f"Это окно таблицы: {table_name}")

        sizer = wx.BoxSizer(wx.VERTICAL)
        sizer.Add(back_button, 0, wx.ALL, 5)
        sizer.Add(add_button, 0, wx.ALL, 5)
        sizer.Add(delete_button, 0, wx.ALL, 5)
        sizer.Add(edit_button, 0, wx.ALL, 5)
        sizer.Add(text, 0, wx.ALL, 20)
        self.SetSizerAndFit(sizer)

        self.previous_panel = previous_panel

        # Создаем пустую панель для отображения содержимого таблицы
        self.table_content_panel = wx.Panel(self)

    def on_back_button_click(self, event):
        self.Destroy()
        self.previous_panel.Show()

    def on_add_button_click(self, event):
        # Создаем окно для добавления записи
        add_dialog = AddRecordDialog(self)
        if add_dialog.ShowModal() == wx.ID_OK:
            # Получаем данные из окна и выполняем соответствующие действия
            record_data = add_dialog.get_record_data()
            # TODO: Добавьте код для добавления записи в таблицу

        add_dialog.Destroy()

    def on_delete_button_click(self, event):
        # Создаем окно для удаления записи
        delete_dialog = DeleteRecordDialog(self)
        if delete_dialog.ShowModal() == wx.ID_OK:
            # Получаем данные из окна и выполняем соответствующие действия
            selected_record = delete_dialog.get_selected_record()
            # TODO: Добавьте код для удаления выбранной записи из таблицы

        delete_dialog.Destroy()

    def on_edit_button_click(self, event):
        # Создаем окно для изменения записи
        edit_dialog = EditRecordDialog(self)
        if edit_dialog.ShowModal() == wx.ID_OK:
            # Получаем данные из окна и выполняем соответствующие действия
            modified_record_data = edit_dialog.get_modified_record_data()
            # TODO: Добавьте код для изменения выбранной записи в таблице

        edit_dialog.Destroy()

    def update_table_content(self, table_data):
        # Очищаем панель с содержимым таблицы
        for child in self.table_content_panel.GetChildren():
            child.Destroy()

        # Создаем элементы интерфейса для отображения данных таблицы
        # TODO: Добавьте код для создания соответствующих элементов интерфейса на self.table_content_panel

        # Обновляем размеры панели с учетом новых элементов интерфейса
        self.table_content_panel.Layout()

        # Помещаем панель с содержимым таблицы на существующую панель
        sizer = self.GetSizer()
        sizer.Add(self.table_content_panel, 1, wx.EXPAND)
        self.Layout()


class SecondFrame(wx.Frame):
    def __init__(self, parent, title, tables):
        wx.Frame.__init__(self, parent, title=title, size=(400, 300))
        panel = wx.Panel(self)

        self.table_panels = []

        # Создаем кнопки для каждой таблицы
        for table in tables:
            button = wx.Button(panel, label=table)
            button.Bind(wx.EVT_BUTTON, self.on_table_button_click)
            self.table_panels.append(button)

        # Размещаем кнопки в вертикальном сетке
        sizer = wx.BoxSizer(wx.VERTICAL)
        for child in panel.GetChildren():
            sizer.Add(child, 0, wx.ALL, 5)
        panel.SetSizerAndFit(sizer)
        self.sizer = sizer

    def on_table_button_click(self, event):
        table_name = event.GetEventObject().GetLabel()
        self.sizer.Hide(0)

        table_window = TableWindow(self, f"Таблица: {table_name}", table_name, panel)
        self.sizer.Add(table_window, 1, wx.EXPAND)
        table_window.SetFocus()
        self.Layout()


if __name__ == '__main__':
    app = wx.App()
    tables = [
        "отделения",
        "врачи",
        "пациенты",
        "диагнозы",
        "история_болезни"
    ]
    frame = SecondFrame(None, "Список таблиц", tables)
    frame.Show()
    app.MainLoop()


