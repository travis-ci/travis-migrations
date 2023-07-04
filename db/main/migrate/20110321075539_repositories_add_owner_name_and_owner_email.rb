# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

class RepositoriesAddOwnerNameAndOwnerEmail < ActiveRecord::Migration[4.2]
  def self.up
    begin
      change_table :repositories do |t|
        t.string :owner_name
        t.string :owner_email
      end
    rescue StandardError
      nil
    end

    begin
      remove_column :repositories, :username
    rescue StandardError
      nil
    end
  end

  def self.down
    begin
      change_table :repositories do |t|
        t.string :username
      end
    rescue StandardError
      nil
    end

    begin
      remove_column :repositories, :owner_name
    rescue StandardError
      nil
    end
    begin
      remove_column :repositories, :owner_email
    rescue StandardError
      nil
    end
  end

  def self.fetch_owner_email(name)
    repository = fetch("repos/show/#{name}")['repository'] || {}
    if name = repository['organization']
      fetch_organization_member_emails(name)
    else
      fetch_user_email(repository['owner'])
    end
  end

  def self.fetch_organization_member_emails(name)
    organization = fetch("organizations/#{name}/public_members")
    emails = organization['users'].map { |member| member['email'] }
    emails.select(&:present?).join(',')
  rescue StandardError
    nil
  end

  def self.fetch_user_email(name)
    user = fetch("user/show/#{name}")
    user['user']['email']
  rescue StandardError
    nil
  end

  def self.fetch(path)
    uri = URI.parse("http://github.com/api/v2/json/#{path}")
    puts "puts fetching #{uri}"
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body)
  rescue StandardError
    {}
  end
end
