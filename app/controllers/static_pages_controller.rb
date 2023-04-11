# frozen_string_literal: true

class StaticPagesController < ApplicationController
  before_action :authenticate_user!

  def home; end
end
