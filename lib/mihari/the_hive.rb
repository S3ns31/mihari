# frozen_string_literal: true

require "net/ping"
require "uri"

module Mihari
  class TheHive
    # @return [true, false]
    def api_endpont?
      ENV.key? "THEHIVE_API_ENDPOINT"
    end

    # @return [true, false]
    def api_key?
      ENV.key? "THEHIVE_API_KEY"
    end

    # @return [true, false]
    def valid?
      api_endpont? && api_key? && ping?
    end

    # @return [Hachi::API]
    def api
      @api ||= Hachi::API.new
    end

    # @return [Array]
    def search(data:, data_type:, range: "all")
      api.artifact.search({ data: data, data_type: data_type }, range: range)
    end

    # @return [Array]
    def search_all(data:, range: "all")
      api.artifact.search({ data: data }, range: range)
    end

    # @return [true, false]
    def exists?(data:, data_type:)
      res = search(data: data, data_type: data_type, range: "0-1")
      !res.empty?
    end

    # @return [Array<Mihari::Artifact>]
    def find_non_existing_artifacts(artifacts)
      data = artifacts.map(&:data)
      results = search_all(data: data)
      keys = results.map { |result| result.dig("data") }.compact.uniq
      artifacts.reject do |artifact|
        keys.include? artifact.data
      end
    end

    # @return [Hash]
    def create_alert(title:, description:, artifacts:, tags: [])
      api.alert.create(
        title: title,
        description: description,
        artifacts: artifacts,
        tags: tags,
        type: "external",
        source: "mihari"
      )
    end

    private

    def ping?
      base_url = ENV.fetch("THEHIVE_API_ENDPOINT")
      base_url = base_url.end_with?("/") ? base_url[0..-2] : base_url
      url = "#{base_url}/index.html"

      http = Net::Ping::HTTP.new(url)
      http.ping?
    end
  end
end
