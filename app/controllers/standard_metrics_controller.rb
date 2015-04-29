class StandardMetricsController < ApplicationController
  def index
    @programs = Program.all.decorate
  end
end
