module Pagination
  DEFAULT_PAGINATION_OFFSET = 0
  DEFAULT_PAGINATION_LIMIT = 10

  def limit
    params.fetch(:limit, DEFAULT_PAGINATION_LIMIT).to_i
  end

  def offset
    params.fetch(:offset, DEFAULT_PAGINATION_OFFSET).to_i
  end

  def build_pagination(total = nil)
    {
      "meta" => {
        "offset" => offset,
        "limit" => limit,
        "total" => total
      }
    }
  end
end
