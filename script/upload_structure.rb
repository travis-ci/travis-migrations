#!/usr/bin/env ruby

require 'bundler/setup'
require 's3'

path_to_structure = ARGV[0] || 'db/main/structure.sql'
path = File.expand_path("../../#{path_to_structure}", __FILE__)
structure = File.read(path)

service = S3::Service.new(access_key_id: ENV['ARTIFACTS_KEY'],
                          secret_access_key: ENV['ARTIFACTS_SECRET'])

bucket = service.buckets.find('travis-migrations-structure-dumps')
object = bucket.objects.build("structure-#{ENV['TRAVIS_BUILD_NUMBER']}.sql")
object.content = structure
object.acl = :public_read
object.save

puts "structure.sql was saved and uploaded to S3:\n#{object.url}"
