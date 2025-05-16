module Phones
    class Import
      def self.call(file)
        # Счётчик успешно импортированных телефонов
        $phones_imported_count = 0
  
        # Парсим файл .xlsx, берём первый лист
        sheet = RubyXL::Parser.parse(file)[0]
  
        # Считываем заголовки из первой строки
        header_row = sheet[0]
        headers = header_row.cells.map { |c| c&.value.to_s }
  
        # Определяем индексы для требуемых колонок
        department_index = headers.index("БЦ")
        name_index = headers.index("ФИО")
        position_index = headers.index("Должность")
        number_index = headers.index("Внутренний")
        mobile_index = headers.index("Мобильный")
        email_index = headers.index("Электронка")
  
        # Проверяем наличие обязательных заголовков
        unless position_index && name_index
          raise ArgumentError, "Файл не содержит необходимые заголовки: 'ФИО', 'Должность'"
        end
  
        # Обрабатываем строки данных, начиная со второй строки (индекс 1)
  sheet[1..-1].each do |row|
    # Считываем значения из строки
    cells = row.cells.map { |c| c&.value.to_s.strip }
  
    # Обрабатываем значение "Внутренний" (number)
    number = cells[number_index.to_i]
    if number.blank? # Проверяем, если значение пустое или nil
      number = 'нет' # Подставляем "нет номера"
    end
  
    # Создаём объект Phone
    phone = Phone.new(
      department: cells[department_index.to_i],
      name: cells[name_index.to_i],
      position: cells[position_index.to_i],
      number: number, # Уже обработанное значение
      mobile: cells[mobile_index.to_i],
      email: cells[email_index.to_i],
    )
  
    # Сохраняем объект, логируем ошибки при необходимости
    if phone.save
      $phones_imported_count += 1
    else
      Rails.logger.warn("Телефон #{phone.number} не был импортирован. Ошибки: #{phone.errors.full_messages}")
    end
  end
  
      end
    end
  end