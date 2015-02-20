require 'open-uri'

# wrapper for S3
class Amazon
  def self.store_file(file, dir = nil)
    aws_file_name = build_aws_file_name(file, dir)
    o = bucket.objects[aws_file_name]
    o.write(file: file, content_type: file.content_type)
    aws_file_name  # requester should save this
  end

  def self.delete_file(aws_file)
    check_trash_bucket
    o = bucket.objects[aws_file]
    o.move_to(o.key, bucket_name: aws_bucket_deleted)
  end

  def self.file_url(aws_file_name)
    o = bucket.objects[aws_file_name]
    o.url_for(:read, secure: false)
  end

  def self.bucket
    find_or_create_bucket aws_bucket
  end

  def self.trash_bucket
    find_or_create_bucket aws_bucket_deleted
  end

  def self.check_trash_bucket
    trash_bucket
  end

  def self.build_aws_file_name(file, dir)
    dt = Time.now.strftime('%m%d%y%H%M%S') # do we want timestamp?
    dir_path = Account.subdomain + '/' + (dir && "#{dir}/").to_s
    dir_path + dt + file.original_filename
  end

  def self.find_or_create_bucket(b)
    s3 = AWS::S3.new
    bkt = s3.buckets[b]
    return bkt if bkt.exists?
    s3.buckets.create(b)
  end

  def self.delete_bucket(bucket_name)
    s3 = AWS::S3.new
    bkt = s3.buckets[bucket_name]
    return unless bkt.exists?
    bkt.clear!
    bkt.delete
  end

  def self.file_list(dir = nil)
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

  def self.recycle_bin_files
    list = []
    trash_bucket.objects.each do |obj|
      list << obj.key
    end
    list
  end

  def self.empty_recycle_bin
    trash_bucket.objects.each { |obj| obj.delete }
  end

  def self.original_file_name(name)
    name_parts = name.split('/')
    bare_name = name_parts[-1]
    bare_name[12..-1]
  end

  private

  def self.aws_bucket
    'managee2e-' + Rails.env
  end

  def self.aws_bucket_deleted
    aws_bucket + '-deleted'
  end
end
