# require 'google/apis/drive_v3'

class Drive
  include Singleton
  # d = Drive.instance

  # attr_accessor :drive
  def initialize floder_name="06.GA自動報表"
    @session = GoogleDrive::Session.from_config((Rails.root+"config.json").to_s)
    @folder = @session.collection_by_title(floder_name)
    # byebug
    # @folder = gd.collection_by_title(floder_name)
  end

  def add file_name, com_name, year=Date.today.year, month="#{'%02d' % Date.today.month}月", file_path="#{Rails.root}/public/xls".to_s
    begin
      # byebug if Rails.env=="development"
      folder1 = @folder.subcollection_by_title(com_name)
      folder1 = @folder.create_subcollection(com_name) if folder1.nil?
      #
      #   folder = @folder.subcollection_by_title(com_name)
      # end

      folder2 = folder1.subcollection_by_title(year)
      folder2 = folder1.create_subcollection(year) if folder2.nil?
      #
      #   folder = @folder.subcollection_by_title(year)
      # end

      folder3 = folder2.subcollection_by_title(month)
      folder3 = folder2.create_subcollection(month) if folder3.nil?
      #
      #   folder = @folder.subcollection_by_title(month)
      # end

      file = @session.upload_from_file("#{file_path}/#{file_name}", file_name, convert: false) if folder3

      folder3.add(file)
      # byebug if Rails.env=="development"
    rescue
      # byebug if Rails.env=="development"
    end
  end

  def create_floder name, folder=@folder
    folder.create_subcollection(name)
  end

  def create_floders names
    f = @folder
    names.each {|name| f = f.create_subcollection(name) }
  end
end
