require 'open-uri'

# wrapper for S3
class Amazon
  class << self
    def store_file(file, dir = nil)
      aws_file_name = build_aws_file_name(file, dir)

      obj = bucket.object(aws_file_name)
      obj.put(body: file.read)

      aws_file_name # requester should save this
    end

    def delete_file(aws_file)
      unless file_exists?(aws_file)
        Rails.logger.error "AWS delete called on non existing file #{aws_file}"
        return
      end

      check_trash_bucket
      o = bucket.object(aws_file)
      o.move_to(key: o.key, bucket: aws_bucket_deleted)

    rescue StandardError => e
      Rails.logger.error "AWS Delete failed for #{aws_bucket}/#{aws_file} #{e}"
    end

    def file_url(aws_file_name, secure: false)
      o = bucket.objects[aws_file_name]
      o.url_for(:read, secure: secure)
    end

    def bucket
      find_or_create_bucket aws_bucket
    end

    def trash_bucket
      find_or_create_bucket aws_bucket_deleted
    end

    def check_trash_bucket
      trash_bucket
    end

    def build_aws_file_name(file, dir)
      dt = Time.now.strftime('%m%d%y%H%M%S') # do we want timestamp?
      dir_path = "#{[Account.subdomain, dir].compact.join('/')}/"
      dir_path + dt + file.original_filename
    end

    def find_or_create_bucket(b)
      bkt = s3.bucket(b)
      return bkt if bkt.exists?

      s3.create_bucket(bucket: b)
    end

    def delete_bucket(bucket_name)
      bkt = s3.bucket(bucket_name)
      return unless bkt.exists?

      bkt.objects.each(&:delete)
      bkt.delete
    end

    def file_list(dir = nil)
      list = []
      bucket.objects.each do |obj|
        if dir
          list << obj if obj.key.split('/')[1] == dir
        else
          list << obj
        end
      end
      list
    end

    def recycle_bin_files
      list = []
      trash_bucket.objects.each do |obj|
        list << obj.key
      end
      list
    end

    def empty_recycle_bin
      trash_bucket.objects.each(&:delete)
    end

    def original_file_name(name)
      name_parts = name.split('/')
      bare_name = name_parts[-1]
      bare_name[12..-1]
    end

    def file_exists?(name)
      bucket.object(name).exists?
    end

    private

    def s3
      @s3 ||= Aws::S3::Resource.new
    end

    def aws_bucket
      prefix = ENV['AWS_BUCKET_PREFIX']
      raise 'AWS_BUCKET_PREFIX not defined' unless prefix

      "#{prefix}-#{Rails.env}"
    end

    def aws_bucket_deleted
      "#{aws_bucket}-deleted"
    end
  end
end
