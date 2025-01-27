class Api::V1::ServicesController < ::ApiController
  def index
    respond_to do |format|
      format.json {
        render json: Service.all, each_serializer: ServiceSerializer
      }
    end
  end
end
