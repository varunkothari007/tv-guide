require 'aws-sdk-s3'

Aws.config.update({
  region: (ENV['REGION'] || "us-east-1"),
  credentials: Aws::Credentials.new((ENV['AWS_ID'] || "AKIA5HTOXFFUAZHLZ7UO"), (ENV['AWS_SECRET'] || "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"))
})