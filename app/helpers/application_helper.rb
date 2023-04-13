# frozen_string_literal: true

# helper methods
module ApplicationHelper
  def asset_exists?(filename, extension)
    asset_pathname = "#{Rails.root}/app/assets/"
    asset_file_path = "#{asset_pathname}/#{filename}".split('.')[0]
    !Dir.glob("#{asset_file_path}.#{extension}*").empty?
  end

  def js_asset_exists?(filename)
    asset_exists?("javascripts/#{filename}", 'js')
  end

  def css_asset_exists?(filename)
    asset_exists?("stylesheets/#{filename}", 'css')
  end

  def page_specific_js_asset(c_name, a_name)
    return index_page_js_asset(c_name) if a_name == 'index'

    asset_name = "#{c_name}/#{a_name}"
    js_asset_exists?(asset_name) ? asset_name : nil
  end

  def index_page_js_asset(c_name)
    asset_name = "#{c_name}/indirect_index"
    return asset_name if js_asset_exists?(asset_name)

    asset_name = "#{c_name}/index"
    js_asset_exists?(asset_name) ? asset_name : nil
  end
end
