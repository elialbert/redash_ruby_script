class RedashApiError < StandardError; end

class RedashApi
  def initialize
    @url = ENV["REDASH_URL"]
    @api_key = ENV["REDASH_API_KEY"]
    @headers = {"Authorization" => "Key #{@api_key}", "Content-type" => "application/json"}
  end

  def get_results(query_id, params)
    params = {parameters: params, max_age: 0}
    url = "#{@url}/api/queries/#{query_id}/results"
    resp = HTTParty.post(url, headers: @headers, body: params.to_json)
    job_id = resp.dig("job", "id")
    if job_id
      get_job_result(job_id)
    else
      error = result.dig("job", "error")
      raise RedashApiError, "Error: #{error}"
    end
  end

  def get_job_result(job_id)
    url = "#{@url}/api/jobs/#{job_id}"
    query_result_id = nil
    while query_result_id.nil?
      resp = HTTParty.get(url, headers: @headers)
      if !resp["job"]
        raise RedashApiError, "Error: #{resp}"
      elsif resp.dig("job", "error")&.present?
        raise RedashApiError, "Error: #{resp.dig("job", "error")}"
      else
        query_result_id = resp.dig("job", "query_result_id")
      end
    end

    data = HTTParty.get("#{@url}/api/query_results/#{query_result_id}", headers: @headers)
    data.dig("query_result", "data", "rows") || raise(RedashApiError, "Error: #{data}")
  end
end
