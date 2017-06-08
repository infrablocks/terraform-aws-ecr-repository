require 'aws-sdk'

module Awspec::Helper
  module Finder
    def sns_client
      @sns_client ||= Aws::SNS::Client.new
    end
  end
end