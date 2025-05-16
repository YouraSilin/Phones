class Phone < ApplicationRecord
    validates :name, presence: { message: " не может быть пустым" }
end
