class Admin
  class AwsS3sController < ApplicationController
    before_filter :authenticate_admin!

    def show
    end

    def index
      @s3_files = Amazon.file_list
    end

    def recycle_bin
      @s3_files = Amazon.recycle_bin_files
    end

    def empty_recycle_bin
      Amazon.empty_recycle_bin
      @s3_files = []
      render 'recycle_bin'
    end
  end
end
