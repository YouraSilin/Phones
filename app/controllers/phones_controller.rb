class PhonesController < ApplicationController

  before_action :authorize_admin, only: [:create, :edit, :update, :destroy]

  
  
    # GET /phones or /phones.json
    def index
      respond_to do |format|
        format.html do
          @phones = fetch_phones
        end
  
        format.xlsx do
          @phones = Phone.order(:created_at)
          render xlsx: 'Телефоны', template: 'phones/phone'
        end
      end
    end
  
    # Импорт телефонов
    def import
      begin
        result = Phones::Import.call(params[:file])
        redirect_to phones_path, notice: "#{result.imported_count} строк импортировано"
      rescue StandardError => e
        redirect_to phones_path, alert: "Ошибка импорта: #{e.message}"
      end
    end
  
    # Удаление всех телефонов
    def delete_all
      Phone.destroy_all
      redirect_to phones_path, notice: 'Все телефоны успешно удалены.'
    end
  
  
  # GET /phones/1 or /phones/1.json
  def show
    @phone = Phone.find(params[:id])
  end

  # GET /phones/new
  def new
    @phone = Phone.new
  end

  # GET /phones/1/edit
  def edit
    @phone = Phone.find(params[:id])
  end

  # POST /phones or /phones.json
  def create
    @phone = Phone.new(phone_params)

    respond_to do |format|
      if @phone.save
        format.html { redirect_to phones_path, notice: "Запись сохранена" }
        format.json { render :show, status: :created, location: @phone }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @phone.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /phones/1 or /phones/1.json
  def update
    @phone = Phone.find(params[:id]) # Найдем телефон по его ID
    respond_to do |format|
      if @phone.update(phone_params)
        format.html { redirect_to phones_path, notice: "Запись сохранена" }
        format.json { render :show, status: :ok, location: @phone }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @phone.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def import
    Phones::Import.call(params[:file])
    redirect_to phones_path, notice: "#{$phones_imported_count} строк импортировано"
  end

  def destroy
    @phone = Phone.find(params[:id])
    @phone.destroy
    redirect_to phones_path, notice: 'Запись удалена'
  end
  
  def delete_all
    Phone.delete_all # Удаляет все записи без вызова коллбеков
    redirect_to phones_path, notice: 'Все телефоны успешно удалены.'
  end
  
  # Only allow a list of trusted parameters through.
  def phone_params
    params.require(:phone).permit(:department, :name, :position, :number, :mobile, :email)
  end

  private
  
    def fetch_phones
      phones = Phone.all
  
      # Применяем фильтр по департаменту, если нужно
      phones = filter_by_department(phones) if params[:department].present?
  
      # Применяем сортировку
      phones.order(
        Arel.sql('CASE WHEN phones.number IS NOT NULL THEN 0 ELSE 1 END ASC'),
        Arel.sql('number ASC NULLS LAST'),
        :name
      )
    end
  
    def filter_by_department(phones)
      phones.where(department: params[:department])
    end
  
    def search_query(phones)
      query = "%#{params[:query]}%"
      phones.where("department ILIKE :query OR name ILIKE :query OR position ILIKE :query OR number ILIKE :query OR mobile ILIKE :query OR email ILIKE :query", query: query)
    end

  def authorize_admin
    redirect_to phones_path, alert: 'У вас нет прав для этого действия.' unless current_user&.admin?
  end
end