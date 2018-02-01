require 'google/apis/drive_v3'

drive = Google::Apis::DriveV3::DriveService.new
user = User.find(4)
drive.authorization = Authorizer.credentials(user.email)
