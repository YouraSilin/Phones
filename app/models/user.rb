class User < ApplicationRecord
  
  # Devise модули
  devise :database_authenticatable, :registerable,
     :recoverable, :rememberable, :validatable
  
  # Установим роли
  enum role: { viewer: 'viewer', admin: 'admin' }
  
  # Зададим роль по умолчанию
  after_initialize do
  self.role ||= :viewer
  
  end

end