# frozen_string_literal: true

class StaticPagesController < ApplicationController
  before_filter :authenticate_user!

  def home; end
end
