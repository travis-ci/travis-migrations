#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'aws-sdk-s3'

path_to_structure = ARGV[0] || 'db/main/structure.sql'
path = File.expand_path("../../#{path_to_structure}", __FILE__)
structure = File.read(path)

s3_client = Aws::S3::Client.new(access_key_id: ENV['ARTIFACTS_KEY'],
                                secret_access_key: ENV['ARTIFACTS_SECRET'],
                                region: ENV['AWS_REGION'])

bucket_name = 'travis-migrations-structure-dumps'
object_key = "structure-#{ENV['TRAVIS_BUILD_NUMBER']}.sql"

s3_client.put_object(
  bucket: bucket_name,
  key: object_key,
  body: structure,
  acl: 'public-read'
)

puts "structure.sql was saved and uploaded to S3:\nhttps://#{bucket_name}.s3.amazonaws.com/#{object_key}"
