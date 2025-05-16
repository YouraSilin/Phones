class PhonesController < ApplicationController

  before_action :authorize_admin, only: [:create, :edit, :update, :destroy]

  @phones = Phone.all.sort_by do |phone|
    [phone.number.nil? ? 1 : 0, phone.number || '', phone.name || '']
  end
  
    # GET /phones or /phones.json
  def index
    respond_to do |format|
      format.html do
        # Базовая выборка телефонов
        @phones = Phone.all
  
        # Фильтры по департаменту
        if params[:department].present?
          @phones = @phones.where(department: params[:department])
        end
  
        # Поиск по имени или номеру
        if params[:query].present?
          query = "%#{params[:query]}%"
          @phones = @phones.where("department ILIKE :query OR name ILIKE :query OR position ILIKE :query OR number ILIKE :query OR mobile ILIKE :query OR email ILIKE :query", query: query)
        end
  
        # Сортировка записей
        @phones = @phones.order(
          Arel.sql('CASE WHEN phones.number IS NOT NULL THEN 0 ELSE 1 END ASC'),
          Arel.sql('number ASC NULLS LAST'),
          :name
        )
      end
  
      format.xlsx do
        @phones = Phone.order(:created_at)
        render xlsx: 'Телефоны', template: 'phones/phone'
      end
    end
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

  def authorize_admin
    redirect_to phones_path, alert: 'У вас нет прав для этого действия.' unless current_user&.admin?
  end
end