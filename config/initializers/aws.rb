require 'aws-sdk-s3'

Aws.config.update({
  region: ENV['REGION'],
  credentials: Aws::Credentials.new(ENV['AWS_ID'], ENV['AWS_SECRET'])
})
