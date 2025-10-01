class ApplicationClient
  # A basic API client with HTTP methods
  #
  # The Authorization Bearer token header for authentication is included by default
  # You can override the `authorization_header` method to change this
  #
  # Content Type is application/json by default
  # You can override the `content_type` to
  #
  # An example API client:
  #
  #   class DigitalOceanClient < ApplicationClient
  #     BASE_URI = "https://api.digitalocean.com/v2"
  #
  #     def account
  #       get("/account").account
  #     rescue *NET_HTTP_ERRORS
  #       raise Error, "Unable to load your account"
  #     end
  #   end

  # Common HTTP Errors
  # See `handle_response` to add more error types as needed
  class Error < StandardError; end

  class MovedPermanently < Error; end

  class Forbidden < Error; end

  class Unauthorized < Error; end

  class UnprocessableContent < Error; end

  class RateLimit < Error; end

  class NotFound < Error; end

  class InternalError < Error; end

  BASE_URI = "https://example.org"
  NET_HTTP_ERRORS = [Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError]

  attr_reader :auth, :basic_auth, :token

  def self.inherited(client)
    response = client.const_set(:Response, Class.new(Response))
    response.const_set(:PARSER, Response::PARSER.dup)

    client.const_set(:Error, Class.new(Error))
    client.const_set(:MovedPermanently, Class.new(MovedPermanently))
    client.const_set(:Forbidden, Class.new(Forbidden))
    client.const_set(:Unauthorized, Class.new(Unauthorized))
    client.const_set(:UnprocessableContent, Class.new(UnprocessableContent))
    client.const_set(:RateLimit, Class.new(RateLimit))
    client.const_set(:NotFound, Class.new(NotFound))
    client.const_set(:InternalError, Class.new(InternalError))
  end

  # Initializes an API client
  #
  # To provide authentication credentials, you can supply either `auth` or `token`.
  #
  #   `auth` should be an object that responds to the `token` method
  #   `token` should be a String authentication token or API key
  #
  # Override this method if the API requires additional parameters
  def initialize(auth: nil, basic_auth: nil, token: nil)
    @auth, @basic_auth, @token = auth, basic_auth, token
  end

  # Override to customize default headers
  # Content-Type will be removed on GET requests
  # Returns a Hash
  def default_headers
    {
      "Accept" => content_type,
      "Content-Type" => content_type
    }.merge(authorization_header)
  end

  # Override to customize the content type
  # Returns a String
  def content_type = "application/json"

  # Override to customize the authorization header
  # Returns a Hash
  #
  # Examples:
  #
  #   { "X-API-Key" => token }
  #   { "AccessKey" => token }
  def authorization_header = {"Authorization" => "Bearer #{auth&.token || token}"}

  # Override to customize default query params
  # Returns a Hash
  def default_query_params = {}

  # Loops through a URL with pagination
  # Each request yields the response to the provide block
  #
  # The block should return a string URL or a hash of query parameters for the next page
  # Return nil to stop paginating
  def with_pagination(path, headers: {}, query: nil)
    page_query = query.dup

    loop do
      next_page = yield get(path, headers: headers, query: page_query)

      case next_page
      when String
        path = next_page
      when Hash
        page_query.merge!(next_page)
      else
        break
      end
    end
  end

  # Make a GET request
  # Pass `headers: {}` to add or override default headers
  # Pass `query: {}` to add query parameters
  #
  #   get("/tweets/1")
  #   => GET /tweets/1
  #
  #   get("/tweets/1", query: {foo: :bar})
  #   => GET /tweets/1?foo=bar
  #
  #  get("/tweets/1", headers: {"Content-Type" => "application/xml")
  #  => GET /tweets/1
  #  => Content-Type: application/xml
  def get(path, **) = make_request(klass: Net::HTTP::Get, path: path, **)

  # Make a POST request
  # Pass `headers: {}` to add or override default headers
  # Pass `query: {}` to add query parameters
  # Pass `body: {}` to add a JSON body to the request
  # Pass `form_data: {}` to add form data to the request (multipart/form-data)
  def post(path, **) = make_request(klass: Net::HTTP::Post, path: path, **)

  # Make a PATCH request
  # Pass `headers: {}` to add or override default headers
  # Pass `query: {}` to add query parameters
  # Pass `body: {}` to add a body to the request
  # Pass `form_data: {}` to add form data to the request (multipart/form-data)
  def patch(path, **) = make_request(klass: Net::HTTP::Patch, path: path, **)

  # Make a PUT request
  # Pass `headers: {}` to add or override default headers
  # Pass `query: {}` to add query parameters
  # Pass `body: {}` to add a body to the request
  # Pass `form_data: {}` to add form data to the request (multipart/form-data)
  def put(path, **) = make_request(klass: Net::HTTP::Put, path: path, **)

  # Make a DELETE request
  # Pass `headers: {}` to add or override default headers
  # Pass `query: {}` to add query parameters
  # Pass `body: {}` to add a body to the request
  def delete(path, **) = make_request(klass: Net::HTTP::Delete, path: path, **)

  # Returns the BASE_URI from the current class
  def base_uri = self.class::BASE_URI

  # Override to set timeouts for all requests
  def open_timeout = nil

  def read_timeout = nil

  def write_timeout = nil

  # Makes an HTTP request
  #   `klass` should be a Net::HTTP::Request class such as Net::HTTP::Get
  #   `path` is a String for the URL path without the protocol and domain. For example: "/api/v1/me"
  #   `headers:` is a Hash of HTTP headers
  #   `body:` can be a string, Hash, or any other object that can be serialized to a string
  #   `query:` is hash of query parameters to append to the path. For example: {foo: :bar} will add "?foo=bar" to the URL path
  #   `http_options: {open_timeout: 60, read_timeout: 60, write_timeout: 60}` is a hash of options for Net::HTTP
  def make_request(klass:, path:, headers: {}, body: nil, query: nil, form_data: nil, http_options: {})
    raise ArgumentError, "Cannot pass both body and form_data" if body.present? && form_data.present?

    # If a full URL is passed in, use that, otherwise append to the base URI
    uri = path.start_with?("http") ? URI(path) : URI("#{base_uri}#{path}")

    # Merge query params with any currently in `path`
    query_params = Rack::Utils.parse_query(uri.query).with_defaults(default_query_params)

    # Merge query params for this request
    case query
    when String
      query_params.merge! Rack::Utils.parse_query(query)
    when Hash
      query_params.merge! query
    end

    uri.query = Rack::Utils.build_query(query_params) if query_params.present?

    Rails.logger.debug("#{klass.name.split("::").last.upcase}: #{uri}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.instance_of? URI::HTTPS

    http.open_timeout = http_options[:open_timeout] || open_timeout || http.open_timeout
    http.read_timeout = http_options[:read_timeout] || read_timeout || http.read_timeout
    http.write_timeout = http_options[:write_timeout] || write_timeout || http.write_timeout

    all_headers = default_headers.merge(headers)

    # Remove Content-Type if there is no body
    all_headers.delete("Content-Type") if klass == Net::HTTP::Get

    request = klass.new(uri.request_uri, all_headers)
    request.basic_auth(basic_auth[:username], basic_auth[:password]) if basic_auth.present?

    if body.present?
      request.body = build_body(body)
    elsif form_data.present?
      request.set_form(form_data, "multipart/form-data")
    end

    handle_response self.class::Response.new(http.request(request))
  end

  # Handles an HTTP response
  # - Parse the response code
  # - Raise an error if not 20X
  # - If response body, parses and returns
  # - Otherwise returns nil
  def handle_response(response)
    case response.code
    when "200", "201", "202", "203", "204"
      response
    when "301"
      raise self.class::MovedPermanently, response.body
    when "401"
      raise self.class::Unauthorized, response.body
    when "403"
      raise self.class::Forbidden, response.body
    when "404"
      raise self.class::NotFound, response.body
    when "422"
      raise self.class::UnprocessableContent, response.body
    when "429"
      raise self.class::RateLimit, response.body
    when "500"
      raise self.class::InternalError, response.body
    else
      raise self.class::Error, "#{response.code} - #{response.body}"
    end
  end

  # Converts a body to the matching ContentType
  # Override this to convert request bodies to other content types
  def build_body(body)
    case body
    when String
      body
    else
      body.to_json
    end
  end

  class Response
    # Provides easy access to the parsed response body as well as the response object headers and status code.
    #
    # To add customer content type parser, register it in the PARSER hash:
    #
    #   class MyClient < ApplicationClient
    #     Response::PARSER["text/html"] = ->(response) { Nokogiri::HTML(response.body) }
    #   end
    #
    # To parse JSON as a Hash instead:
    #
    #   class MyClient < ApplicationClient
    #     Response::PARSER["application/json"] = ->(response) { JSON.parse(response.body) }
    #   end

    PARSER = {
      "application/json" => ->(response) { JSON.parse(response.body, object_class: ActiveSupport::InheritableOptions) },
      "application/xml" => ->(response) { Nokogiri::XML(response.body) }
    }
    FALLBACK_PARSER = ->(response) { response.body }

    attr_reader :original_response

    delegate :code, :body, to: :original_response
    delegate_missing_to :parsed_body

    def initialize(original_response)
      @original_response = original_response
    end

    # Returns a hash of headers with underscored names as symbols
    def headers
      @headers ||= original_response.each_header.to_h.transform_keys { |k| k.underscore.to_sym }
    end

    # Returns a hash of the Link header
    # If there is no Link header, returns an empty hash
    #
    # For example:
    #   <https://api.github.com/repositories/1300192/issues?page=2>; rel="prev", <https://api.github.com/repositories/1300192/issues?page=4>; rel="next", <https://api.github.com/repositories/1300192/issues?page=515>; rel="last", <https://api.github.com/repositories/1300192/issues?page=1>; rel="first"
    #
    #   {
    #     next: "https://...",
    #     prev: "https://...",
    #     first: "https://...",
    #     last: "https://...",
    #   }
    def link_header
      @link_header ||= headers[:link]&.split(", ")&.map do |link|
        rel = link[/rel="(.+)"/, 1].to_sym
        url = link[/<(.+)>/, 1]
        [rel, url]
      end.to_h
    end

    # Removes charset and boundary and returns the mime type
    #
    # Given:
    #   Content-Type: application/json; charset=utf-8
    #
    # Returns:
    #   "application/json"
    def content_type = headers[:content_type]&.split(";")&.first

    def parsed_body
      @parsed_body ||= self.class::PARSER.fetch(content_type, FALLBACK_PARSER).call(self)
    end
  end
end
